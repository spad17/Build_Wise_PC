require "test_helper"

class AuthenticationTest < ActionDispatch::IntegrationTest
  test "registers, signs in automatically, and keeps the session across requests" do
    assert_difference("User.count", 1) do
      post signup_path, params: {
        user: {
          username: "Alice",
          email: "Alice@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    user = User.last
    assert_redirected_to root_path
    assert_equal user.id, session[:user_id]

    get root_path
    assert_select "strong", "Alice"
    get my_builds_path
    assert_response :success
    assert_select "a", "Мои сборки"
  end

  test "rejects a duplicate email without creating another user" do
    create_user(email: "existing@example.com")

    assert_no_difference("User.count") do
      post signup_path, params: {
        user: {
          username: "Another",
          email: "EXISTING@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_select ".error-box"
  end

  test "signs in with a valid password and rejects an invalid password" do
    create_user(email: "login@example.com")

    post login_path, params: { session: { email: "LOGIN@example.com", password: "password123" } }
    assert_redirected_to root_path
    assert_equal User.find_by(email: "login@example.com").id, session[:user_id]

    delete logout_path
    assert_nil session[:user_id]

    post login_path, params: { session: { email: "login@example.com", password: "wrong-password" } }
    assert_response :unprocessable_entity
    assert_select ".flash-alert", /Неверный email или пароль/
    assert_nil session[:user_id]
  end

  test "requires login for private pages and returns after login" do
    create_user
    get my_builds_path
    assert_redirected_to login_path
    assert_equal "/my-builds", session[:return_to]

    post login_path, params: { session: { email: "test@example.com", password: "password123" } }
    assert_redirected_to my_builds_path
    follow_redirect!
    assert_response :success
  end

  test "shows public header links and logout button when authenticated" do
    get root_path
    assert_select "a", "Войти"
    assert_select "a", "Регистрация"
    assert_select "form[action='#{logout_path}']", count: 0

    create_user
    post login_path, params: { session: { email: "test@example.com", password: "password123" } }
    get root_path
    assert_select "form[action='#{logout_path}'][method='post']"
  end

  test "logout is only available via DELETE and clears the session" do
    create_user(email: "logout@example.com")
    post login_path, params: { session: { email: "logout@example.com", password: "password123" } }

    delete logout_path
    assert_redirected_to root_path
    get root_path
    assert_select "a", "Войти"
    assert_select "a", "Регистрация"
  end
end
