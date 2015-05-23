ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "minitest/reporters"
Minitest::Reporters.use!

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
  # Include modules you should like to use in your tests.
  include ApplicationHelper
  # Add more helper methods to be used by all tests here...
  def assert_contains(expected_string, actual)
    assert actual.include? expected_string
  end

  def is_logged_in?
    !session[:user_id].nil?
  end
end
