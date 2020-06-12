Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'http://dev-okidb.china-revival.com/'
    resource '/api/*', headers: :any, methods: [:get,:options]
  end
end