class LuceneController < ApplicationController
  def index
    body = RestClient.get("http://10.27.3.39:9200/_cat/indices/?format=json&pretty&s=docs.count:desc").body
    indices = JSON.parse(body)
    @indices = Kaminari.paginate_array(indices, total_count: indices.count).page(params[:page]).per(100)

  end
end
