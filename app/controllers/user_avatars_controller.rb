class UserAvatarsController < ApplicationController
	before_action :logged_in_user
	before_action :correct_user

  def edit

  end

  def update
  	image_info = params[:avatar]||""
    if image_info.include? "data:image/png"
      png = Base64.decode64(image_info['data:image/png;base64,'.length .. -1])
      File.open(Rails.root+"public/test.png", 'wb') { |f| f.write(png) }
      current_user.avatar = File.open(Rails.root+"public/test.png")
      current_user.save
  	  flash[:success] = "保存成功！"
    else
  	  flash[:error] = "保存失败！"
    end
  	redirect_to edit_user_avatar_path(current_user)
  end

  private

  # 确保是正确的用户
  def correct_user
    @user = User.find_by_id(params[:id])
    redirect_to root_path unless current_user?(@user)
  end
end
