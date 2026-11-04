ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
abort('Tests must not run in production!') if Rails.env.production?
require 'rspec/rails'
require 'spec_helper'

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.use_transactional_fixtures = true
end
