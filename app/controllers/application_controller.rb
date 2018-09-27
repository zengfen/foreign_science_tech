class ApplicationController < ActionController::Base
  include SessionsHelper
  # protect_from_forgery with: :exception

  before_action :invalid_check

  private
  # 确保用户已登录
  def logged_in_user
    unless logged_in?
      store_location
      flash[:notice] = "请先登录！"
      redirect_to login_path
    end
  end

  def test_account
    if @current_user.email == "test@china-revival.com"
      redirect_to action: "index"
      return
    end
  end

  def invalid_check
    @expired_account_count = Account.expired_accounts.count
  end
end
