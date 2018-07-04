require_relative 'lib/models'

require 'roda'
require 'tilt/sass'

class App < Roda
  plugin :default_headers,
    'Content-Type'=>'text/html',
    #'Strict-Transport-Security'=>'max-age=16070400;', # Uncomment if only allowing https:// access
    'X-Frame-Options'=>'deny',
    'X-Content-Type-Options'=>'nosniff',
    'X-XSS-Protection'=>'1; mode=block'

  plugin :content_security_policy do |csp|
    csp.default_src :none
    csp.style_src :self
    csp.form_action :self
    csp.script_src :self
    csp.connect_src :self
    csp.base_uri :none
    csp.frame_ancestors :none
  end

  # Don't delete session secret from environment in development mode as it breaks reloading
  session_secret = ENV['RACK_ENV'] == 'development' ? ENV['APP_SESSION_SECRET'] : ENV.delete('APP_SESSION_SECRET')
  use Rack::Session::Cookie,
    key: '_App_session',
    #secure: ENV['RACK_ENV'] != 'test', # Uncomment if only allowing https:// access
    :same_site=>:lax, # or :strict if you want to disallow linking into the site
    secret: (session_secret || SecureRandom.hex(40))

  plugin :static, ["/assets"], root: "public"
  plugin :route_csrf
  plugin :flash
  plugin :render, escape: true,
                  views: File.expand_path("web/views", __dir__)
  plugin :public
  plugin :multi_route

  Unreloader.require('web/routes'){}

  route do |r|
    r.public
    r.assets
    check_csrf!
    r.multi_route

    r.root do
      view 'index'
    end
  end
end
