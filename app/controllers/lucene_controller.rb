class LuceneController < ApplicationController
  def index

    link = "http://10.27.3.39:9200/_cat/indices/?format=json&pretty&s=docs.count:desc"
    unless params[:category].blank? || params[:keyword].blank?
      key = params[:keyword].blank? ? params[:category] : params[:keyword]
      link = "http://10.27.3.39:9200/_cat/indices/*#{key}*?format=json&pretty&s=docs.count:desc"
    end
    Rails.logger.info(link)
    body = RestClient.get(link).body
    indices = JSON.parse(body)
    @indices = Kaminari.paginate_array(indices, total_count: indices.count).page(params[:page]).per(100)

  end
end
