class CommandsController < ApplicationController

  def index
    current_command = $archon_redis.get("controller_command")
    if !current_command.blank?
      @current_command = JSON.parse(current_command)
    end
  end


  def new
  end

  def create
    command = params[:command]

    if !$archon_redis.exists("controller_command")
      $archon_redis.set("controller_command", {"command" => command, "command_magic" => Time.now.to_i.to_s }.to_json)
      $archon_redis.expire("controller_command", 60) # 1分钟过期
    end

    redirect_to action: :index
  end


  def new_supervisor
    {
      "supervisor_stop" => "重启"
    }
  end

end
