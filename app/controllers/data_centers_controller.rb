class DataCentersController < ApplicationController
  def index
    @results = ArchonBase.table_metas
  end

  def show
    table_name = params[:table_name]
    tag_id = params[:tag_id]
    if !tag_id.blank? && table_name.blank?
      return redirect_to "/data_centers/show"
    end

    if !table_name.blank?
      @name = ArchonBase.model_mapper.invert[table_name]
      @results = eval((table_name + '_tag').camelize)

      unless tag_id.blank?
        @results = @results.where(tag: tag_id)
      end

      @results = @results.includes(:record).page(params[:page]).per(20).without_count
    end
  end

  def record_details
    table_name = params[:table_name]
    id = params[:id]
    if !table_name.blank? && !id.blank?
      @record = eval(table_name.camelize)
      if table_name == 'archon_facebook_post'
        @record = @record.includes(:user).find(id).to_json(include: [:user])
      elsif table_name == 'archon_facebook_comment'
        @record = @record.includes(:user).find(id).to_json(include: [:user])
      elsif table_name == 'archon_twitter' || table_name == 'archon_weibo'
        @record = @record.includes(%i[user retweet_user]).find(id).to_json(include: [:user, :retweet_user])
      else
        @record = @record.find(id).to_json
      end

      @record = JSON.parse(@record)
    end
  end
end
