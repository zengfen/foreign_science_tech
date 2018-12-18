# encoding: utf-8
require "rails"
require "rest_client"

class TwitterEmotionAnalysis
  # twitter数据情感分析
  class << self

    # 更新数据的 pos_neg 和 pos_neg_score
    # nohup rails r TwitterEmotionAnalysis.update_twitter_pos_neg &
    def update_twitter_pos_neg
      tags = redis.smembers(tags_key)
      tags = [24]
      tags.each do |tag|
        while true
          offset_key = tag_offset_id_key
          offset_id = $redis.hget(offset_key, tag) || 0
          res = ArchonTwitterTag.where("id > #{offset_id} and tag = #{tag}").order("id asc").limit(10000)
          ids = res.pluck(:pid)
          break if ids.blank?
          offset_id = res.last.id
          $redis.hset(offset_key, tag, offset_id)
          deal_batch_data(ids)
        end
      end

    end

    def deal_batch_data(ids)
      datas = []
      ArchonTwitter.select("id, source_url, created_time").where(id:ids).find_each do |tw|
        res = analysis_result(tw)
        datas << {id: tw.id, pos_neg: res["polarity"], pos_neg_score: res["score"], updated_at: Time.now}
      end
      destination_columns = [:id,:pos_neg,:pos_neg_score,:updated_at]
      ArchonTwitter.bulk_insert(*destination_columns, update_duplicates: true, ignore: true, values:datas)
    end



    # 调用获取情感分析api
    def analysis_result(tw)
      params = {}
      params[:global_id] = ""
      params[:tweet] = ""
      params[:url] = tw.source_url
      params[:date_time] = tw.created_time.strftime("%F %T")
 
      url = analysis_url
      retry_count = 3
      res = {}
      begin
        res = RestClient.post(url, params)
        res = JSON.parse(res) rescue {}
      rescue Exception => e
        if retry_count > 0
          retry_count -= 1
          retry
        end
      end
      return res
    end

    def analysis_url
      "http://47.96.96.39:8009/twitter_sentiment"
    end

    # 读取 ArchonTwitterTag 表的数据，存储tag
    # nohup rails r TwitterEmotionAnalysis.read_archon_twitter_tags &
    def read_archon_twitter_tags
      offset_id = $redis.get(archon_titter_tag_offset_id_key) || 0
      key = tags_key
      ArchonTwitterTag.select(:tag,:id).where("id > #{offset_id}").find_each do |x|
        $redis.sadd(key, x.tag)
      end
    end

    # 存储tags的key ac_tea 是 archon_center_twitter_emotion_analysis 缩写
    def tags_key
      "ac_tea_archon_twitter_tags"
    end

    # 存储 ArchonTwitterTag 表的offset_id的key
    def archon_titter_tag_offset_id_key
      "ac_tea_archon_twitter_tag_offset_id"
    end


    # 存储 ArchonTwitter 表每个tag当前的offset_id的key
    def archon_titter_offset_id_key
      "ac_tea_archon_twitter_offset_id"
    end





  end
end