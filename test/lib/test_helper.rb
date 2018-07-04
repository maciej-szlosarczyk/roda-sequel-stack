ENV["RACK_ENV"] = "test"
require_relative '../../lib/models'
raise "test database doesn't end with test" unless DB.opts[:database] =~ /test\z/
require_relative '../minitest_helper'
