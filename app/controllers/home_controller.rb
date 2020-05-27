class HomeController < ApplicationController
  before_action :logged_in_user

  def index
    @runing_count               = 0
    @total_data_count           = 0
    @today_completed_count      = 0
    @total_completed_count      = 0
    @today_discard_count        = 0
    @total_discard_count        = 0
    @today_already_runing_count = 0
    @total_already_runing_count = 0

    # @today_completed_count = ServiceCounter.today_completed_task_count
    # @today_discard_count   = ServiceCounter.today_discard_task_count
    #
    # @runing_count = ServiceCounter.running_task_count
    #
    # @total_data_count = ServiceCounter.total_result_count
    #
    # @total_completed_count = ServiceCounter.total_completed_task_count
    #
    # @total_discard_count = ServiceCounter.total_discard_task_count
    #
    # @today_already_runing_count = @today_completed_count + @today_discard_count
    # @total_already_runing_count = @total_completed_count + @total_discard_count

    # @recent_finished_tasks = SpiderTask.includes('spider').where(status: SpiderTask::TypeTaskCompleted, special_tag: "30214").order('updated_at desc').page(params[:page]).per(5)
    # @recent_running_tasks  = SpiderTask.includes('spider').where(status: SpiderTask::TypeTaskRunning, special_tag: "30214").order('updated_at desc').page(params[:page]).per(5)
  end

end
