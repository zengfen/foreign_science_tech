class DataCentersController < ApplicationController
  def index
    @results = ArchonBase.table_metas
  end

  def show
    table_name = params[:id]
    tag_id = params[:tag_id]
    if !tag_id.blank? && table_name.blank?
      return redirect_to "/data_centers/show"
    end

    if !table_name.blank? && !ArchonBase.model_mapper.invert[table_name].blank?
      @name = ArchonBase.model_mapper.invert[table_name]
      @results = eval((table_name + '_tag').camelize)

      unless tag_id.blank?
        @results = @results.where(tag_id: tag_id)
      end

      @results = @results.includes(:record).page(params[:page]).per(20)
    end
  end

  def record_details
    if !table_name.blank? && !ArchonBase.model_mapper.invert[table_name].blank?
      @name = ArchonBase.model_mapper.invert[table_name]

      @results = eval((table_name + '_tag').camelize)

      if table_name == 'archon_facebook_post'
        @results = @results.includes(record: :user)
      elsif table_name == 'archon_facebook_comment'
        @results = @results.includes(record:  :user)
      elsif table_name == 'archon_twitter' || table_name == 'archon_weibo'
        @results = @results.includes(record: %i[user retweet_user])
      else
        @results = @results.includes(:record)
      end

      @results = @results.page(params[:page]).per(20)
    end
  end
end
