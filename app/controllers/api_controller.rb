class ApiController < ApplicationController
  def create_location_monitor_task
    secret = params[:secret]
    return render json: { msg: 'error secret' } if secret != '123'

    # template_id = 40

    # keyword = |35.45664166|139.44451388|5km|en


    @spider_task = SpiderTask.new(
      spider_id: 40,
      level: 1,
      max_retry_count: 0,
      keyword: params[:keyword],
      special_tag: params[:special_tag],
      status: 0,
      task_type: 2,
      is_split: false,
    )
    @spider_task.special_tag_transfor_id
    @spider_task.save_with_spilt_keywords
    @spider_task.start!


    details = {
      id: @spider_task.id.to_s,
      created_at: Time.now.to_i,
      table_name: "twitter",
      tag_id: @spider_task.special_tag.to_i,
    }

    $archon_redis.hset("okidb_dumper_task_details", @spider_task.id, details.to_json)
    $archon_redis.zadd("okidb_dumper_task_ids", Time.now.to_i + 10, @spider_task.id)


    render json: {archon_task_id: @spider_task.id, archon_special_tag_id: @spider_task.special_tag.to_i}
  end


  def create_normal_task
    secret = params[:secret]
    return render json: { msg: 'error secret' } if secret != '123'
    return render json: { msg: 'error spider_id' } if params[:spider_id].blank?
    return render json: { msg: 'error keyword' } if params[:keyword].blank?

    @spider_task = SpiderTask.new(
      spider_id: params[:spider_id],
      level: 1,
      max_retry_count: 0,
      keyword: params[:keyword],
      special_tag: params[:special_tag],
      status: 0,
      task_type: 2,
      is_split: false,
      additional_function: params[:additional_function],
    )
    @spider_task.special_tag_transfor_id
    @spider_task.save_with_spilt_keywords
    @spider_task.start!


    render json: {status:"ok",archon_task_id: @spider_task.id, archon_special_tag_id: @spider_task.special_tag}
  end

  def show_normal_task
    secret = params[:secret]
    return render json: { msg: 'error secret' } if secret != '123'
    return render json: { msg: 'error task_id' } if params[:task_id].blank?
    @spider_task = SpiderTask.find(params[:task_id]) rescue {msg: "not found"}
    render json: {status:"ok",task:@spider_task}
  end

  def destroy_normal_task
    secret = params[:secret]
    return render json: { msg: 'error secret' } if secret != '123'
    return render json: { msg: 'error task_id' } if params[:task_id].blank?
    @spider_task = SpiderTask.find(params[:task_id]) rescue nil
    if !@spider_task.nil?
      @spider_task.destroy
    end
    render json: {status:"ok"}
  end

  def task_api
    secret = params[:secret]
    return render json: { msg: 'error secret' } if secret != '123'

    resulst = []
    keywords = params[:keywords] rescue []
    keywords = [] if keywords.blank?
    SpiderTask.includes("spider").where(task_type:1).each do |x|
      task = JSON.parse(x.to_json)
      spider = JSON.parse(x.spider.to_json)
      keywords.each do |k|
        if !x.keyword.blank? &&(x.keyword.downcase.include?(k.downcase) || k.downcase.include?(x.keyword.downcase))
          resulst << {task:task,spider:spider}
        elsif x.spider.spider_name.include?(k.downcase) || k.downcase.include?(x.spider.spider_name)
          resulst << {task:task,spider:spider}
        end
      end
    end

    render json: {resulst:resulst}

  end

  def task_api_all
    secret = params[:secret]
    return render json: { msg: 'error secret' } if secret != '123'

    resulst = []
    SpiderTask.includes("spider").where(task_type:1).each do |x|
      task = JSON.parse(x.to_json)
      spider = JSON.parse(x.spider.to_json)
      resulst << {task:task,spider:spider}
    end

    render json: {resulst:resulst}

  end

  def cycle_task_api_all
    secret = params[:secret]
    return render json: { msg: 'error secret' } if secret != '123'

    resulst = []
    SpiderCycleTask.includes("spider").each do |x|
      task = JSON.parse(x.to_json)
      spider = JSON.parse(x.spider.to_json)
      resulst << {task:task,spider:spider}
    end

    render json: {resulst:resulst}
  end

  def cycle_task_api
    secret = params[:secret]
    return render json: { msg: 'error secret' } if secret != '123'

    resulst = []
    keywords = params[:keywords] rescue []
    keywords = [] if keywords.blank?
    SpiderCycleTask.includes("spider").each do |x|
      task = JSON.parse(x.to_json)
      spider = JSON.parse(x.spider.to_json)
      keywords.each do |k|
        if !x.keyword.blank? &&(x.keyword.downcase.include?(k.downcase) || k.downcase.include?(x.keyword.downcase))
          resulst << {task:task,spider:spider}
        elsif x.spider.spider_name.include?(k.downcase) || k.downcase.include?(x.spider.spider_name)
          resulst << {task:task,spider:spider}
        end
      end
    end

    render json: {resulst:resulst}
  end

  def list_normal_tasks
    secret = params[:secret]
    return render json: { msg: 'error secret' } if secret != '123'
    return render json: { msg: 'error spider_id' } if params[:spider_id].blank?
    status = params[:status]

    @spider_task = SpiderTask.where(spider_id: params[:spider_id], status: status)
    render json: {tasks: @spider_task.collect(&:id)}
  end

end
