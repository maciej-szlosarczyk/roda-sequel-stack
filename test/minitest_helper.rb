# frozen_string_literal: true

# Configure test coverage
require "simplecov"
require "simplecov-console"

unless ENV["SIMPLE_COVERAGE_REPORTER"]
  SimpleCov.formatter = SimpleCov::Formatter::Console
end

SimpleCov.start do
  coverage_dir("tmp/coverage")
  add_filter "test"
  add_filter ".env.rb"

  minimum_coverage(90)
  minimum_coverage_by_file(80)
end

gem "minitest"
require "minitest/autorun"
require "minitest/hooks/default"
require "minitest/reporters"

# Fixtures are needed here
require "sequel"
require "fixture_dependencies/helper_methods"
require "timecop"

# Base test class, both TwinCamIntegrationTest and
# TwinCamModelTest inherit from it.
class AppTest < Minitest::Test
  include Minitest::Hooks
  Minitest::Reporters.use!(
    [Minitest::Reporters::DefaultReporter.new(color: true)]
  )

  # Fixture Setup
  FixtureDependencies.fixture_path = "test/fixtures"

  def load_fixture(fixture)
    FixtureDependencies.load(fixture)
  end
end
