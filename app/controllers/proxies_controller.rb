class ProxiesController < ApplicationController
  def index
    page = (params[:page] || '1')
    page = page.to_i

    total_count = $archon_redis.llen('archon_proxies')

    start_index = (page - 1) * 10
    end_index = page * 10 - 1

    results = $archon_redis.lrange('archon_proxies', start_index, end_index)

    @proxies = Kaminari.paginate_array(results, total_count: total_count)
                       .page(params[:page]).per(10)
  end
end
