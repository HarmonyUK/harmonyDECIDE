# frozen_string_literal: true

# Remove the default X-Frame-Options header
# Our CSP frame-src directive handles embedding permissions instead

# Middleware to remove X-Frame-Options header
class RemoveXFrameOptionsMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)
    
    # Remove X-Frame-Options to allow CSP frame-src to control embedding
    headers.delete('X-Frame-Options')
    
    [status, headers, body]
  end
end

# Register the middleware
Rails.application.config.middleware.insert_after ActionDispatch::ShowExceptions, RemoveXFrameOptionsMiddleware
