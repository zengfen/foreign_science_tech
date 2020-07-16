Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.seconds.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = true
  # config.action_mailer.delivery_method = :letter_opener
  config.action_mailer.delivery_method   = Setting.mailer_provider.to_sym

  config.action_mailer.default_url_options = { host: Setting.domain}

  if Setting.mailer_provider == 'postmark'
    config.action_mailer.postmark_settings = Setting.mailer_options.deep_symbolize_keys rescue "postmark_settings"
  else
    config.action_mailer.smtp_settings = Setting.mailer_options.deep_symbolize_keys rescue "smtp_settings"
  end

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # When a console cannot be shown for a given IP address or content type, a messages like the following is printed in the server logs:
  # Cannot render console from 192.168.1.133! Allowed networks: 127.0.0.0/127.255.255.255, ::1
  #If you don't wanna see this message anymore, set this option to false
  config.web_console.whiny_requests = false

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker
end
