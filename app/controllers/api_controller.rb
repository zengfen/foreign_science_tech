class ApiController < ApplicationController
  def create_location_monitor_task
    secret = params[:secret]
    return render json: { msg: 'error secret' } if secret != '123'

    # template_id = 40

    # keyword = |35.45664166|139.44451388|5km|en


    @spider_task = SpiderTask.new(
      spider_id: 40,
      level: 1,
      max_retry_count: 1,
      keyword: params[:keyword],
      special_tag: params[:special_tag],
      status: 0,
      task_type: 2,
      is_split: false,
    )
    @spider_task.special_tag_transfor_id
    @spider_task.save_with_spilt_keywords
    # @spider_task.start!


    details = {
      id: @spider_task.id.to_s,
      created_at: Time.now.to_i,
      table_name: "twitter",
      tag_id: @spider_task.special_tag.to_i,
    }

    $archon_redis.hset("okidb_dumper_task_details", @spider_task.id, details.to_json)
    $archon_redis.zadd("okidb_dumper_task_ids", Time.now.to_i + 10, @spider_task.id)


    render json: {archon_task_id: @spider_task.id}
  end
end
