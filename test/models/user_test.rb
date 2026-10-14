require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "requires a username and valid email" do
    user = User.new(email: "invalid", password: "password123", password_confirmation: "password123")

    assert_not user.valid?
    assert_includes user.errors[:username], "не может быть пустым"
    assert_includes user.errors[:email], "имеет неверный формат"
  end

  test "email uniqueness is case insensitive" do
    User.create!(username: "First", email: "Person@example.com", password: "password123", password_confirmation: "password123")
    duplicate = User.new(username: "Second", email: "person@EXAMPLE.com", password: "password123", password_confirmation: "password123")

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:email], "уже существует"
  end

  test "stores only a password digest" do
    user = User.create!(username: "Secure", email: "secure@example.com", password: "password123", password_confirmation: "password123")

    assert user.password_digest.present?
    assert_not user.password_digest.include?("password123")
    assert user.authenticate("password123")
  end
end
