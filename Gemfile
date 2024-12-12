source 'https://rubygems.org'

ruby '3.3.6'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '8.0.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'terser'

# Use CoffeeScript for .coffee assets and views

gem 'haml-rails'

gem 'jquery-rails'

gem 'turbolinks', '~> 5'

gem 'bootstrap', '~> 5.0.0'

gem 'activerecord', '~> 8.0.0'
gem 'bcrypt', '~> 3.1.7'
gem 'ffi', '~> 1.15' # Or the latest compatible version
gem 'rails-ujs', '~> 0.1.0'

gem 'mini_magick'

gem 'dotenv-rails'
group :development, :test do
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'devise'
  gem 'factory_bot_rails'
  gem 'rails-controller-testing'
  gem 'rspec-rails'
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem 'shoulda-matchers'
  gem 'sqlite3', '~> 2.1'
  gem 'webmock'
  # gem 'capybara'
  # gem 'selenium-webdriver'
  gem 'simplecov', require: false
end

group :development do
end

group :production do
  gem 'pg', '~> 1.5'
  gem 'rails_12factor'
end