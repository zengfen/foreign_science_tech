Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # origins EVN["API_ACESS_HOST"] || "*"
    origins "dev-okidb.china-revival.com"
    resource '/api/*', headers: :any, methods: [:get,:options]
  end
end