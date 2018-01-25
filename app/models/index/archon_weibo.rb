class ArchonWeibo

  def self.table_name
    "archon_weibo"
  end


  def self.create_index(date)
    $elastic = Elasticsearch::Client.new hosts:[{ host: "10.46.226.135",port: "9200",user: "elastic",password: "changeme"},{ host: "10.27.3.39",port: "9200",user: "elastic",password: "changeme"},{ host: "10.28.46.145",port: "9200",user: "elastic",password: "changeme"},{ host: "10.28.46.192",port: "9200",user: "elastic",password: "changeme"}],randomize_hosts: true, log: false,send_get_body_as: "post"
    es_table_name = "#{table_name}_#{date}"
    if !($elastic.indices.exists? index: "#{es_table_name}")
      index_body(es_table_name)
    end
  end

  def self.recreate_index(date)
    $elastic = Elasticsearch::Client.new hosts:[{ host: "10.46.226.135",port: "9200",user: "elastic",password: "changeme"},{ host: "10.27.3.39",port: "9200",user: "elastic",password: "changeme"},{ host: "10.28.46.145",port: "9200",user: "elastic",password: "changeme"},{ host: "10.28.46.192",port: "9200",user: "elastic",password: "changeme"}],randomize_hosts: true, log: false,send_get_body_as: "post"
    es_table_name = "#{table_name}_#{date}"
    if $elastic.indices.exists? index: "#{es_table_name}"
      $elastic.indices.delete index:"#{es_table_name}"
    end
    index_body(es_table_name)
  end

  def self.index_body(es_table_name)
    $elastic.indices.create index: "#{es_table_name}", type:"#{es_table_name}", body: {
      settings: {
        index: {
          number_of_shards: 10,
          number_of_replicas: 1
        }
      },
      mappings: {
        "#{es_table_name}": {
          _all: {
            analyzer: "ik_max_word",
            search_analyzer: "ik_max_word",
          },
          properties: {
            site: {type: 'keyword', index:'not_analyzed'},
            created_at: {type: 'date', index:'not_analyzed'},
            updated_at: {type: 'date', index:'not_analyzed'},
            created_time: {type: 'date', index:'not_analyzed'},
            title: {type: 'text', analyzer: 'ik_max_word',search_analyzer: "ik_max_word" },
            desp: {type: 'text', analyzer: 'ik_max_word',search_analyzer: "ik_max_word" },
            view_count: {type: 'integer', index: 'not_analyzed' },
            comment_count: {type: 'integer', index: 'not_analyzed' },
            repost_count: {type: 'integer', index: 'not_analyzed' },
            like_count: {type: 'integer', index: 'not_analyzed' },
            dislike_count: {type: 'integer', index: 'not_analyzed' },
            source: {type: 'keyword', index: 'not_analyzed' },
            source_type: {type: 'keyword', index: 'not_analyzed' },
            in_reply_to_status_id: {type: 'keyword', index: 'not_analyzed' },
            in_reply_to_user_id: {type: 'keyword', index: 'not_analyzed' },
            in_reply_to_screen_name: {type: 'keyword', index: 'not_analyzed' },
            is_long_text: {type: 'keyword', index: 'not_analyzed' },
            user_id: {type: 'keyword', index: 'not_analyzed' },
            user_name: {type: 'keyword', index: 'not_analyzed' },
            user_province: {type: 'keyword', index: 'not_analyzed' },
            user_city: {type: 'keyword', index: 'not_analyzed' },
            user_location: {type: 'keyword', index: 'not_analyzed' },
            user_description: {type: 'keyword', index: 'not_analyzed' },
            user_profile_image_url: {type: 'keyword', index: 'not_analyzed' },
            user_profile_url: {type: 'keyword', index: 'not_analyzed' },
            user_gender: {type: 'keyword', index: 'not_analyzed' },
            user_followers_count: {type: 'keyword', index: 'not_analyzed' },
            user_friends_count: {type: 'keyword', index: 'not_analyzed' },
            user_statuses_count: {type: 'keyword', index: 'not_analyzed' },
            user_created_at: {type: 'date', index: 'not_analyzed' },
            user_verified: {type: 'keyword', index: 'not_analyzed' },
            user_verified_type: {type: 'keyword', index: 'not_analyzed' },
            special_tags: {type: 'keyword', index: 'not_analyzed' },
          }
        }
      }
    }
  end
end
