# 爬虫日志
# log_spider_id
# spider_name 爬虫名
# start_time 启动时间
# mode 启动模式  0：周期启动，1：实时启动
class TLogSpider < CommonBase
  self.table_name = "t_log_spider"

  CycleMode = 0
  RealTimeMode = 1



end
