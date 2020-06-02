class TestController < ApplicationController

  def list
    model_tasks = eval(params["spider_name"]).new.list(params["body"])
    return render json:model_tasks
  end

  def item
    model_tasks = eval(params["spider_name"]).new.item(params["body"])
    return render json:model_tasks

  end
end