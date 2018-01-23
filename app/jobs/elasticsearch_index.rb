class ElasticsearchIndex < ApplicationJob
  queue_as :default

  def perform(category,dates)
    dates.each do |date|
      category.classify.constantize.create_index(date)
    end
  end
end
