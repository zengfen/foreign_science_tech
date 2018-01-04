class SpidersController < ApplicationController
	before_action :get_spider, only: [:show,:show_info, :load_edit_form, :update, :destroy]
	
	def index
		params[:category]||=-1
		opts = {}
		opts[:category] = params[:category] if  params[:category]!=-1
    opts[:spider_name] = params[:keyword] if !params[:keyword].blank?
		@spiders = Spider.where(opts).order("created_at desc").page(params[:page]).per(10)
		@spider = Spider.new
	end


	def show
		
	end

	def show_info
		
	end

	def create
		@spider = Spider.build_spider(spider_params)
		if @spider.save
		 flash[:success] = "创建成功"
		else
		 flash[:error] = @spider.errors.full_messages.join('\n')
		end
		 redirect_to spiders_path
	end

	def load_edit_form
		
	end

	def update
		update_params = spider_params.clone
		additional_function = update_params.delete(:additional_function)

		begin
			update_params[:additional_function] = JSON.parse(additional_function)
		rescue
			@spider.errors.add(:additional_function,"格式错误")
		end
		
		if @spider.update_attributes(update_params)
      flash[:success] = "更新成功！"
    else
    	flash[:error] = @spider.errors.full_messages.join('\n')
    end

     redirect_to spiders_path
	end

	def destroy
		@spider.destroy
		redirect_to spiders_path
	end

	private

	def spider_params
		params.require(:spider).permit(:spider_name, :spider_type, :network_environment, :proxy_support,:has_keyword,:template_name,:category,:additional_function)
	end

	def get_spider
		@spider = Spider.find_by(:id=>params[:id])
		redirect_to root_path if @spider.blank?
	end
end
