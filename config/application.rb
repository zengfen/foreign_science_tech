require_relative 'boot'


require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ArchonCenter
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    # config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.eager_load_paths << Rails.root.join('app/models/common')
    # config.eager_load_paths << Rails.root.join('app/models/archon')
    # config.eager_load_paths << Rails.root.join('app/models/rs')
    # config.eager_load_paths << Rails.root.join('app/models/monitor_client_app')
    # config.eager_load_paths << Rails.root.join('app/models/new_archon')
    config.eager_load_paths += Dir["#{config.root}/lib/"]
    config.eager_load_paths += Dir["#{config.root}/lib/site_tasks"]


    config.autoload_paths += ["#{config.root}/lib"]
    config.autoload_paths += ["#{config.root}/lib/site_tasks"]

    config.i18n.default_locale = 'zh-CN'
    config.active_record.default_timezone = :local
    config.time_zone = 'Beijing'
    config.active_job.queue_adapter = :sidekiq
  end
end

begin
  # $redis = Redis.new(:host => "47.99.44.207", :port => 9529, :db => 5,:password=>"Devpro321")
  $redis = Redis.new(:host => "127.0.0.1", :port => 6379, :db => 1)

  #RsDataDB = Rails.application.config_for(:database, env: "rs_data")

  CommonDataDB = Rails.application.config_for(:database, env: "common_data")

rescue Exception => e
  puts e
end




