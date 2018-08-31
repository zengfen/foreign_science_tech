class ArchonBase < ActiveRecord::Base
  self.abstract_class = true
  establish_connection ArchonDataDB

  def self.model_mapper
    {
      '新闻' => 'archon_news',
      # '论坛' => 'archon_bbs',
      '微博' => 'archon_weibo',
      '视频' => 'archon_video',
      '视频评论' => 'archon_video_comment',
      # '电商' => 'archon_electric_business',
      '图片' => 'archon_picture',
      '图片评论' => 'archon_picture_comment',
      '字幕' => 'archon_timed_text',
      # '问答' => 'archon_question',
      # '社交' => 'archon_sns_post',
      # '博客' => 'archon_blog',
      # '招聘' => 'archon_hiring',
      # '新闻评论' => 'archon_news_comment',
      '酒店评论' => 'archon_hotel_comment',
      'Facebook' => 'archon_facebook_post',
      'Facebook评论' => 'archon_facebook_comment',
      'Twitter' => 'archon_twitter',
      'Linkedin' => 'archon_linkedin',
      "商户" => "archon_place",
      "景区评论" => "archon_scenic_comment",
      "Okidb临时人物" => "archon_temp_person_record"
    }
  end


  def self.table_metas
    temp_metas = {}
    ArchonBase.connection.execute("show STATS_META where db_name = '#{ArchonDataDB['database']}'").to_a.each do |x|
      temp_metas[x[1]] = [x[1], x[2], x[3], x[4]]
    end

    metas = []
    model_mapper.each do |k, v|
      puts k
      metas << [k, v] + temp_metas[v.tableize]
    end

    metas << ["Twitter用户", "archon_twitter_user"] + temp_metas["archon_twitter_users"]
    metas << ["Twitter关注", "archon_twitter_friend"] + temp_metas["archon_twitter_friends"]
    metas
  end
end
