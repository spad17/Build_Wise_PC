require "test_helper"
require_relative "../support/configurator_catalog"

class ConfiguratorTest < ActionDispatch::IntegrationTest
  include ConfiguratorCatalog
  setup { load_configurator_catalog }

  def sign_in(email = "test@example.com")
    create_user(email: email)
    post login_path, params: { session: { email: email, password: "password123" } }
  end

  def create_build
    post builds_path, params: { build: { name: "Мой ПК", platform: "x86-64", purpose: "Игры", budget_rubles: 100_000, wishes: "32 ГБ ОЗУ, SSD 1 ТБ" } }
    Build.last
  end

  test "happy path registers builds browses replaces locks reviews and signs out" do
    get new_build_path
    assert_redirected_to login_path
    post signup_path, params: { user: { username: "Happy", email: "happy@example.com", password: "password123", password_confirmation: "password123" } }
    assert_redirected_to new_build_path
    get new_build_path
    assert_response :success
    build = create_build
    assert_redirected_to build_path(build)
    follow_redirect!
    assert_response :success
    assert_select ".part-row", count: 8
    assert build.reload.complete_configuration?
    get my_builds_path
    assert_select "a", "Мой ПК"
    part = build.components.find_by!(category: "gpu")
    get components_path, params: { category: "gpu", build_id: build.id }
    assert_response :success
    get component_path(part), params: { modal: "1", build_id: build.id }
    assert_response :success
    assert_select "h2", /Отзывы пользователей/
    assert_not_includes response.body, "<!DOCTYPE html>"
    replacement = Component.find_by!(name: "SAPPHIRE PULSE Radeon RX 6600 8 ГБ")
    patch replace_component_build_path(build), params: { component_id: replacement.id }
    assert_redirected_to build_path(build)
    assert_includes build.reload.components, replacement
    locked = build.components.find_by!(category: "cpu")
    patch optimize_build_path(build), params: { locked_ids: [locked.id], build: { wishes: "32 ГБ ОЗУ, SSD 1 ТБ" } }
    assert build.build_items.find_by!(component: locked).locked?
    patch replace_component_build_path(build), params: { component_id: Component.find_by!(name: "Intel Core i3-12100F").id }
    assert_equal locked.id, build.reload.components.find_by!(category: "cpu").id
    post component_reviews_path(part), params: { review: { rating: 5, body: "Подошла для моей сборки." } }
    assert_redirected_to component_path(part)
    get component_path(part)
    assert_select ".review", /Подошла для моей сборки/
    delete logout_path
    get build_path(build)
    assert_redirected_to login_path
  end

  test "failed optimization leaves original configuration and budget intact" do
    sign_in
    build = create_build
    ids = build.components.pluck(:id).sort
    budget = build.budget_cents
    patch optimize_build_path(build), params: { build: { budget_rubles: 10000, wishes: "128 ГБ ОЗУ" } }
    assert_redirected_to build_path(build)
    assert_equal ids, build.reload.components.pluck(:id).sort
    assert_equal budget, build.budget_cents
    assert_equal "32 ГБ ОЗУ, SSD 1 ТБ", build.wishes
  end

  test "budget limits are enforced on server without saving invalid builds" do
    sign_in
    [9999, 5_000_001, "10000oops"].each do |budget|
      assert_no_difference("Build.count") do
        post builds_path, params: { build: { name: "Invalid", platform: "x86-64", purpose: "Игры", budget_rubles: budget } }
      end
      assert_response :unprocessable_entity
    end
  end

  test "another user cannot access modify or delete someone else's build or review" do
    sign_in
    build = create_build
    part = build.components.first
    post component_reviews_path(part), params: { review: { rating: 4, body: "Мой отзыв" } }
    review = Review.last
    delete logout_path
    sign_in("other@example.com")
    get build_path(build)
    assert_response :not_found
    patch optimize_build_path(build)
    assert_response :not_found
    delete build_path(build)
    assert_response :not_found
    patch component_review_path(part, review), params: { review: { body: "Чужая правка" } }
    assert_response :not_found
    delete component_review_path(part, review)
    assert_response :not_found
    assert_equal "Мой отзыв", review.reload.body
  end

  test "reviews require login validate rating prevent duplicates and escape HTML" do
    part = Component.first
    post component_reviews_path(part), params: { review: { rating: 5, body: "Guest" } }
    assert_redirected_to login_path
    sign_in
    assert_no_difference("Review.count") { post component_reviews_path(part), params: { review: { rating: 6, body: "Invalid" } } }
    post component_reviews_path(part), params: { review: { rating: 5, body: "<script>alert('x')</script>" } }
    assert_no_difference("Review.count") { post component_reviews_path(part), params: { review: { rating: 4, body: "Duplicate" } } }
    get component_path(part)
    assert_select ".review script", count: 0
    assert_select ".review p", "<script>alert('x')</script>"
    review = Review.last
    patch component_review_path(part, review), params: { review: { rating: 3, body: "Обновил мнение" } }
    assert_equal 3, review.reload.rating
    delete component_review_path(part, review)
    assert_not Review.exists?(review.id)
  end
end
