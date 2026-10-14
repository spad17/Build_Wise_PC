ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)
    fixtures :all
  end
end

class ActionDispatch::IntegrationTest
  def create_user(attributes = {})
    User.create!({
      username: "Test User",
      email: "test@example.com",
      password: "password123",
      password_confirmation: "password123"
    }.merge(attributes))
  end
end
