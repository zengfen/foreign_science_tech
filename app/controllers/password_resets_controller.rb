class PasswordResetsController < ApplicationController
  before_action :get_user,         only: [:edit, :update]
  before_action :valid_user,       only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]    

  layout 'empty'

  def new
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = "重置邮件已发送，请稍后查收邮件进行修改！"
      redirect_to root_url
    else
      flash.now[:error] = "您所输入的邮箱账户不存在！"
      render 'new'
    end
  end

  def edit
  end

  def update
    if params[:user][:password].empty?                  # 第三种情况
      @user.errors.add(:password, "不能为空")
      flash[:error] = @user.errors.full_messages.join('\n')
      render 'edit'
    elsif @user.update_attributes(user_params)          # 第四种情况
      log_in @user
      flash[:success] = "密码重设成功！"
      redirect_to @user
    else
      render 'edit'                                     # 第二种情况
    end
  end

  private

    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end

    # 前置过滤器

    def get_user
      @user = User.find_by(email: params[:email])
    end

    # 确保是有效用户
    def valid_user
      unless (@user  &&
              @user.authenticated?(:reset, params[:id]))
        redirect_to root_url
      end
    end

    # 检查重设令牌是否过期
    def check_expiration
      if @user.password_reset_expired?
        flash[:error] = "重设密码链接已过期"
        redirect_to new_password_reset_url
      end
    end
end
