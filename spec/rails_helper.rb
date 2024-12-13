# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
require 'factory_bot_rails'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'rspec/rails'
require 'webmock/rspec'

# Add Shoulda Matchers configuration
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

# Requires supporting ruby files with custom matchers and macros, etc., in spec/support/ and its subdirectories.
Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

RSpec.configure do |config|
  # Include Devise helpers for controller specs if using Devise
  config.include Devise::Test::ControllerHelpers, type: :controller

  # Include FactoryBot methods for cleaner syntax
  config.include FactoryBot::Syntax::Methods

  # Set up fixtures path
  config.fixture_paths = ["#{::Rails.root}/spec/fixtures"]

  # Use transactional fixtures
  config.use_transactional_fixtures = true

  # Automatically infer spec types from file locations
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces
  config.filter_rails_from_backtrace!

  # Enable WebMock and disable external requests except localhost
  WebMock.disable_net_connect!(allow_localhost: true)

  # Clean up Active Storage files after the test suite finishes
  config.after(:suite) do
    FileUtils.rm_rf(Dir["#{Rails.root}/tmp/storage"])
  end
end
