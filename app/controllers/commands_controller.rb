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
    @commands = {
      "supervisor_stop" => "重启"
    }

    @current_command = $archon_redis.get("archon_current_command")

    @statuses = {}
    if !@current_command.blank?
      @statuses = $archon_redis.hgetall("archon_host_command_statuses")
    end
  end


  def create_supervisor
    command = params[:command]

    if !$archon_redis.setnx("archon_current_command", command)
      return redirect_to action: :new_supervisor
    end

    $archon_redis.hgetall("archon_hosts").each do |k, v|
      $archon_redis.hset("archon_host_commands", k, command)
      $archon_redis.hset("archon_host_command_statuses", k, "")
    end

    redirect_to action: :new_supervisor
  end

end
