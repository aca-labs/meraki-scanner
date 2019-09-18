# Application dependencies
require "action-controller"
require "active-model"

# Allows request IDs to be configured for logging
# You can extend this with additional properties
class HTTP::Request
  property id : String?
end

# Application code
require "./controllers/application"
require "./controllers/*"
require "./models/*"

# Server required after application controllers
require "action-controller/server"

STDOUT.sync = true

# Add handlers that should run before your application
ActionController::Server.before(
  HTTP::ErrorHandler.new(ENV["SG_ENV"]? != "production"),
  ActionController::LogHandler.new(STDOUT) { |context|
    # Allows for custom tags to be included when logging
    # For example you might want to include a user id here.
    {
      # `context.request.id` is set in `controllers/application`
      request_id: context.request.id,
    }.map { |key, value| " #{key}=#{value}" }.join("")
  },
  HTTP::CompressHandler.new
)

# Configure session cookies
# NOTE:: Change these from defaults
ActionController::Session.configure do |settings|
  settings.key = ENV["COOKIE_SESSION_KEY"]? || "aca_meraki_location"
  settings.secret = ENV["COOKIE_SESSION_SECRET"]? || "4f74c0b358d5bab4000dd3c75465dc2c"
  # HTTPS only:
  settings.secure = ENV["SG_ENV"]? == "production"
end

APP_NAME = "ACA Meraki"
VERSION  = "1.0.0"
