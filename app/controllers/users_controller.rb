class UsersController < ApplicationController
  before_action :logged_in_user, only: [:edit, :update, :show]
  before_action :correct_user,   only: [:edit, :update, :show]
  def new
    @user = User.new
    render :layout => "empty"
  end


  def create
    @user = User.new(user_params)
    if @user.save
      # 处理注册成功的情况
      flash[:success] = "注册成功，请重新登录!"
      redirect_to login_path
    else
      flash[:error] = @user.errors.full_messages.join('\n')
      render 'new',:layout=>"empty"
    end
  end

  def show
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = "更新成功！"
      redirect_to @user
    else
      render 'edit'
    end
  end


  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  # 确保是正确的用户
  def correct_user
    @user = User.find_by_id(params[:id])
    redirect_to(root_url) unless current_user?(@user)
  end
end
