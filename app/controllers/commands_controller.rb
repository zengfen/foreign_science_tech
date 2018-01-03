class CommandsController < ApplicationController

  def index
    current_command = $archon_redis.get("controller_command")
    if !current_command.blank?
      @current_command = JSON.parse(current_command)
    end
  end


  def new
  end

end
