Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    ENV["API_ACESS_HOST"] = "127.0.0.1:8080"
    origins ENV["API_ACESS_HOST"]
    # origins "dev-okidb.china-revival.com"
    # origins "127.0.0.1:8080"
    resource '/api/*', headers: :any, methods: [:get,:options]
  end
end