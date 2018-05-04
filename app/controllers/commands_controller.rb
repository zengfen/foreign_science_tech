class CommandsController < ApplicationController
  def index
    current_command = $archon_redis.get('controller_command')
    @current_command = JSON.parse(current_command) unless current_command.blank?
  end

  # def new; end

  # def create
  #   command = params[:command]

  #   unless $archon_redis.exists('controller_command')
  #     $archon_redis.set('controller_command', { 'command' => command, 'command_magic' => Time.now.to_i.to_s }.to_json)
  #     $archon_redis.expire('controller_command', 60) # 1分钟过期
  #   end

  #   redirect_to action: :index
  # end

  # def new_supervisor
  #   @commands = {
  #     'supervisor_stop' => '重启'
  #   }

  #   @current_command = $archon_redis.get('archon_current_command')

  #   @statuses = {}
  #   unless @current_command.blank?
  #     @statuses = $archon_redis.hgetall('archon_host_command_statuses')
  #   end
  # end

  # def create_supervisor
  #   command = params[:command]

  #   unless $archon_redis.setnx('archon_current_command', command)
  #     return redirect_to action: :new_supervisor
  #   end

  #   $archon_redis.hgetall('archon_hosts').each do |k, _v|
  #     $archon_redis.hset('archon_host_commands', k, command)
  #     $archon_redis.hset('archon_host_command_statuses', k, '')
  #   end

  #   redirect_to action: :new_supervisor
  # end

  def new
    @commands = {
      'agent_restart' => '重启',
      'agent_stop' => '停止',
      "supervisor_stop" => "升级supervisor",
    }

    @current_command = $archon_redis.get('archon_current_command')

    @statuses = {}
    unless @current_command.blank?
      @statuses = $archon_redis.hgetall('archon_host_command_statuses')
    end
  end

  def create
    command = params[:command]

    unless $archon_redis.setnx('archon_current_command', command)
      return redirect_to action: :new
    end

    $archon_redis.hgetall('archon_hosts').each do |k, _v|
      $archon_redis.hset('archon_host_commands', k, command)
      $archon_redis.hset('archon_host_command_statuses', k, '')
    end

    redirect_to action: :new
  end

  def clear
    $archon_redis.del('archon_current_command')
    $archon_redis.del('archon_host_commands')
    $archon_redis.del('archon_host_command_statuses')

    redirect_to action: :new
  end
end
