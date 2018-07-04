require "rake/testtask"

# Migrate
migrate = lambda do |env, version|
  ENV["RACK_ENV"] = env
  require_relative "lib/db"
  require "logger"
  Sequel.extension :migration
  DB.loggers << Logger.new($stdout)
  Sequel::Migrator.apply(DB, "migrate", version)
end

# Migrations
# rubocop:disable BlockLength
namespace :db do
  namespace :dev do
    desc "Migrate development database all the way down"
    task :down do
      migrate.call("development", 0)
    end

    desc "Migrate development database all the way up"
    task :up do
      migrate.call("development", nil)
    end

    desc "Migrate development database down, and then up"
    task :bounce do
      migrate.call("development", 0)
      Sequel::Migrator.apply(DB, "migrate")
    end
  end

  namespace :test do
    desc "Migrate test database all the way down"
    task :down do
      migrate.call("test", 0)
    end

    desc "Migrate test database all the way up"
    task :up do
      migrate.call("test", nil)
    end

    desc "Migrate test database down, and then up"
    task :bounce do
      migrate.call("test", 0)
      Sequel::Migrator.apply(DB, "migrate")
    end
  end

  desc "Apply migrations in production database"
  task :prod do
    migrate.call("production", nil)
  end
end
# rubocop:enable BlockLength

# Shell
pry = proc do |env|
  ENV["RACK_ENV"] = env
  cmd = "pry"
  sh "#{cmd} -r ./lib/models"
end

namespace :pry do
  desc "Open pry in dev environment"
  task :dev do
    pry.call("dev")
  end

  desc "Open pry in test environment"
  task :test do
    pry.call("test")
  end

  desc "Open pry in production environment"
  task :production do
    pry.call("production")
  end
end

desc "Open pry in dev environment"
task pry: "pry:dev"

# Tests
namespace :test do
  Rake::TestTask.new do |t|
    t.name = "other"
    t.description = "Run all tests except for Web ones"
    t.warning = false
    file_list = FileList.new("test/**/*_test.rb").exclude("test/web/*_test.rb")
    t.test_files = file_list
  end

  Rake::TestTask.new do |t|
    t.name = "web"
    t.description = "Run only Web tests"
    t.warning = false
    t.test_files = FileList["test/web/*_test.rb"]
  end

  Rake::TestTask.new do |t|
    t.name = "all"
    t.warning = false
    t.test_files = FileList["test/**/*_test.rb"]
  end
end

desc "Run all tests"
task test: "test:all"

# Utils
desc "give the application an appropriate name"
task :setup, [:name] do |t, args|
  unless name = args[:name]
    $stderr.puts "ERROR: Must provide a name argument: example: rake setup[AppName]"
    exit(1)
  end

  require 'securerandom'
  lower_name = name.gsub(/([a-z\d])([A-Z])/, '\1_\2').downcase
  upper_name = lower_name.upcase

  File.write('.env.rb', <<END)
ENV['RACK_ENV'] ||= 'development'

ENV['#{upper_name}_DATABASE_URL'] ||= case ENV['RACK_ENV']
when 'test'
  ENV['#{upper_name}_SESSION_SECRET'] ||= #{SecureRandom.urlsafe_base64(40).inspect}
  ENV['#{upper_name}_DATABASE_URL'] ||= "postgres:///#{lower_name}_test?user=#{lower_name}"
when 'production'
  ENV['#{upper_name}_SESSION_SECRET'] ||= #{SecureRandom.urlsafe_base64(40).inspect}
  ENV['#{upper_name}_DATABASE_URL'] ||= "postgres:///#{lower_name}_production?user=#{lower_name}"
else
  ENV['#{upper_name}_SESSION_SECRET'] ||= #{SecureRandom.urlsafe_base64(40).inspect}
  ENV['#{upper_name}_DATABASE_URL'] ||= "postgres:///#{lower_name}_development?user=#{lower_name}"
end
END

  %w'web/views/layout.erb web/routes/prefix1.rb config.ru app.rb db.rb
     test/minitest_helper.rb test/web/test_helper.rb package.json'.each do |f|
    File.write(f, File.read(f).gsub('App', name).gsub('APP', upper_name))
  end

  File.write(__FILE__, File.read(__FILE__).split("\n")[0...(last_line-2)].join("\n") << "\n")
  File.delete('public/.gitkeep')
end
