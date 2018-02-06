require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ArchonCenter
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.eager_load_paths << Rails.root.join('app/models/index')

    config.autoload_paths += ["#{config.root}/lib"]
    
    config.i18n.default_locale = 'zh-CN'
    config.active_record.default_timezone = :local
    config.time_zone = 'Beijing'
    config.active_job.queue_adapter = :sidekiq
  end
end


begin
  $archon_redis = Redis.new(Rails.application.config_for(:redis))
  $geo_ip = GeoIP.new('config/GeoIP.dat')
rescue Exception => e
  puts e
end
