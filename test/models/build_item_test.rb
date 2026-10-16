require "test_helper"

class BuildItemTest < ActiveSupport::TestCase
  def setup
    user = User.create!(username: "Parts", email: "parts@example.com", password: "password123", password_confirmation: "password123")
    @build = Build.create!(user: user, name: "Тест", purpose: "Работа", platform: "x86-64", budget_cents: 80_000_00)
    @component = Component.create!(name: "Test CPU", manufacturer: "Test", category: "cpu", platform: "x86-64", socket: "AM5", price_cents: 10_000_00)
  end

  test "requires a positive integer quantity" do
    item = @build.build_items.build(component: @component, quantity: 0)

    assert_not item.valid?
    assert item.errors[:quantity].any?
  end

  test "prevents duplicate components in one build" do
    @build.build_items.create!(component: @component, quantity: 1)
    duplicate = @build.build_items.build(component: @component, quantity: 1)

    assert_not duplicate.valid?
    assert duplicate.errors[:component_id].any?
  end

  test "rejects components from another platform" do
    @build.build_items.create!(component: @component, quantity: 1)
    e2k = Component.create!(name: "E2K CPU", manufacturer: "Elbrus", category: "cpu", platform: "E2K", price_cents: 10_000_00)
    item = @build.build_items.build(component: e2k, quantity: 1)

    assert_not item.valid?
    assert_includes item.errors[:component], "не соответствует платформе сборки"
  end
end
