class ArchonNews

  def self.table_name
    "archon_news"
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
        employee: {
          _all: {
            analyzer: "ik_max_word",
            search_analyzer: "ik_max_word",
          },
          properties: {
            site:{type: 'keyword', index:'not_analyzed'},
            created_at: {type: 'date', index:'not_analyzed'},
            updated_at:{type: 'date', index:'not_analyzed'},
            created_time: {type: 'date', index:'not_analyzed'},
            title: {type: 'text', analyzer: 'ik_max_word',search_analyzer: "ik_max_word" },
            desp: {type: 'text', analyzer: 'ik_max_word',search_analyzer: "ik_max_word" },
            view_count: {type: 'integer', index: 'not_analyzed' },
            comment_count: {type: 'integer', index: 'not_analyzed' },
            repost_count: {type: 'integer', index: 'not_analyzed' },
            like_count: {type: 'integer', index: 'not_analyzed' },
            dislike_count: {type: 'integer', index: 'not_analyzed' },
            source: {type: 'keyword', index: 'not_analyzed' },
            news_tags: {type: 'keyword', index: 'not_analyzed' },
            news_imgs: {type: 'keyword', index: 'not_analyzed' },
            country_name: {type: 'keyword', index: 'not_analyzed' },
            state_name: {type: 'keyword', index: 'not_analyzed' },
            region_name: {type: 'keyword', index: 'not_analyzed' },
            city_name: {type: 'keyword', index: 'not_analyzed' },
            publish_organization: {type: 'keyword', index: 'not_analyzed' },
            special_tags: {type: 'keyword', index: 'not_analyzed' },
          }
        }
      }
    }
  end
end
