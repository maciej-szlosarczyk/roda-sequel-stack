# frozen_string_literal: true

source "https://rubygems.org"

gem "bcrypt"
gem "dry-validation"
gem "erubi"
gem "puma"
gem "rack-unreloader"
gem "rack_csrf"
gem "roda"
gem "rodauth"
gem "sass"
gem "sequel"
gem "sequel_pg"
gem "tilt"

group :development do
  # Required by robe
  gem "pry"
  gem "pry-doc"
end

group :test, :ci do
  gem "capybara"
  gem "capybara-webkit"
  gem "fixture_dependencies"
  gem "minitest"
  gem "minitest-hooks"
  gem "minitest-reporters"
  gem "selenium-webdriver"
  gem "simplecov"
  gem "simplecov-console"
  gem "timecop"
end

group :ci do
  gem "reek"
  gem "rubocop"
end
