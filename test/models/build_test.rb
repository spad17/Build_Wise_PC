require "test_helper"

class BuildTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(username: "Builder", email: "builder@example.com", password: "password123", password_confirmation: "password123")
    @build = Build.create!(user: @user, name: "Игровая сборка", purpose: "Игры", platform: "x86-64", budget_cents: 100_000_00)
    @cpu = Component.create!(name: "Ryzen 7 7800X3D", manufacturer: "AMD", category: "cpu", platform: "x86-64", socket: "AM5", price_cents: 42_990_00)
    @memory = Component.create!(name: "Fury 32 GB", manufacturer: "Kingston", category: "memory", platform: "x86-64", price_cents: 8_490_00)
  end

  test "calculates total and remaining budget from build items" do
    @build.add_component(@cpu)
    @build.add_component(@memory, quantity: 2)

    assert_equal 59_970_00, @build.total_price_cents
    assert_equal 40_030_00, @build.remaining_budget_cents
    assert @build.within_budget?
    assert_equal :ready, @build.readiness
  end

  test "merges repeated components and reports an over-budget build" do
    @build.add_component(@memory, quantity: 2)
    @build.add_component(@memory, quantity: 3)
    expensive = Component.create!(name: "RTX 4090", manufacturer: "NVIDIA", category: "gpu", platform: "x86-64", price_cents: 150_000_00)
    @build.add_component(expensive)

    assert_equal 5, @build.build_items.find_by(component: @memory).quantity
    assert_not @build.within_budget?
    assert_equal :over_budget, @build.readiness
  end

  test "reports an empty build before components are selected" do
    assert_equal 0, @build.total_price_cents
    assert_equal :empty, @build.readiness
  end
end
