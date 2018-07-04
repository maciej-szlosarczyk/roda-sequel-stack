ENV["RACK_ENV"] = "test"
require File.expand_path("../../twin_cam", __dir__)
unless DB.opts[:database].end_with?("test")
  raise "test database doesn't end with test"
end

require "capybara"
require "capybara/dsl"
require "rack/test"
require "selenium/webdriver"

require_relative "../minitest_helper"

Capybara.app = App.freeze.app
Capybara.save_path = "tmp/capybara"

class TwinCamIntegrationTest < TwinCamTest
  include Rack::Test::Methods
  include Capybara::DSL
  include Helpers::LoginHelper

  def app
    Capybara.app
  end

  def teardown
    super

    Capybara.reset_sessions!
    Capybara.use_default_driver
  end

  # Keeps all tests in transactions with savepoint.
  def around
    DB.transaction(rollback: :always, savepoint: true, auto_savepoint: true) do
      super
    end
  end

  def around_all
    DB.transaction(rollback: :always) do
      super
    end
  end

  # MiniTest has this awesome ability of running multiple tests at once.
  parallelize_me!
end

# Base class for integration tests with javascript, whenever you need to write
# a new one:
# class MyNewIntegrationTest < TwinCamRichIntegrationTest
# end
# NOTE: This type of tests does not run in transaction, so it cannot be
#       parallelized. Use sparingly.
class TwinCamRichIntegrationTest < TwinCamTest
  include Rack::Test::Methods
  include Capybara::DSL
  include Helpers::LoginHelper

  Capybara.register_driver(:chrome) do |app|
    options = ::Selenium::WebDriver::Chrome::Options.new

    options.add_argument("--headless")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--window-size=1400,1400")

    Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
  end

  Capybara.register_server(:silent_puma) do |app, port, _host|
    require "rack/handler/puma"
    Rack::Handler::Puma.run(app, Port: port, Threads: "0:2", Silent: true)
  end

  def app
    Capybara.app
  end

  def setup
    super

    Capybara.current_driver = :chrome
    Capybara.server         = :silent_puma
  end

  def teardown
    super

    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
end
