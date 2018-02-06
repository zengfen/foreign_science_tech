class SettingsController < ApplicationController
  before_action :logged_in_user
	def index
		if params[:keyword].blank?
			@settings = Setting.get_all
		else
			@settings  = nil
			value = Setting[params[:keyword]]
			@settings =  { params[:keyword]=>Setting[params[:keyword]]} unless value.blank?
		end
	end

	def create
		if params[:setting_key].blank? ||params[:setting_value].blank?
			flash[:error] = "请填写相应的键值！"
			redirect_back(fallback_location:settings_path)
			return
		end

		value = JSON.parse(params[:setting_value]) rescue params[:setting_value]

		Setting[params[:setting_key]] = value
		redirect_back(fallback_location:settings_path)
	end

	def load_edit_form
		@setting = {params[:setting_key]=> Setting[params[:setting_key]]}
	end

	def update
		if params[:setting_key].blank? ||params[:setting_value].blank?
			flash[:error] = "请填写相应的键值！"
			redirect_back(fallback_location:settings_path)
			return
		end
		value = JSON.parse(params[:setting_value]) #rescue params[:setting_value]
		redirect_back(fallback_location:settings_path)
	end

	def destroy
		setting  = Setting.find_by(var: params[:id])
		return render json: { type: 'error', message: '此为默认配置项不可删除！' } if setting.blank?
		Setting.destroy params[:id].to_sym 
		render json: { type: 'success', message: '操作成功！' }
	end
end
