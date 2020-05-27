class ApplicationController < ActionController::Base
  include SessionsHelper
  # protect_from_forgery with: :exception


  private
  # 确保用户已登录
  def logged_in_user
    unless logged_in?
      store_location
      flash[:notice] = "请先登录！"
      return redirect_to login_path
    end

  end

  def unhandle_count
    opt = {status:[0,1]}
    opt['work_list_employees.employee_id'] = @employee.id unless @employee.blank?
    opt['work_list_employees.mark'] = [0,1,3]

    @work_lists_unhandle_count = WorkList.where(opt).includes(:work_list_employees).count
  end
end
