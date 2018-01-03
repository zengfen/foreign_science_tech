class ApplicationController < ActionController::Base
	include SessionsHelper
  # protect_from_forgery with: :exception

  private
  # 确保用户已登录
  def logged_in_user
    unless logged_in?
    	store_location
      flash[:notice] = "请先登录！"
      redirect_to login_path
    end
  end
end
