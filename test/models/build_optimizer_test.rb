require "test_helper"
require_relative "../support/configurator_catalog"

class BuildOptimizerTest < ActiveSupport::TestCase
  include ConfiguratorCatalog

  setup { load_configurator_catalog }

  test "finds complete compatible builds for x64 and Threadripper" do
    user = User.create!(username: "Architect", email: "architect@example.com", password: "password123")
    %w[x86-64 Threadripper].each do |platform|
      build = user.builds.create!(name: platform, purpose: "Монтаж и 3D", platform: platform, budget_cents: 5_000_000_00)
      parts = BuildOptimizer.new(build).call
      build.replace_configuration!(parts)
      assert_equal 8, build.build_items.count
      assert build.reload.complete_configuration?, platform
    end
  end

  test "reports insufficient real hardware budget and E2K supplier requirement" do
    build = candidate_build(budget: 10_000)
    assert_raises(BuildOptimizer::NoSolution) { BuildOptimizer.new(build).call }
    build.budget_cents = 60_000_00
    parts = BuildOptimizer.new(build).call
    assert_equal 8, parts.size
    assert_operator parts.sum(&:price_cents), :<=, build.budget_cents
    build.platform = "E2K"
    assert_raises(BuildOptimizer::NoSolution) { BuildOptimizer.new(build).call }
  end

  test "honors memory and SSD minimums and preserves fixed parts" do
    build = candidate_build(wishes: "Тихий компьютер, 32 ГБ ОЗУ и SSD 1 ТБ")
    fixed = Component.find_by!(name: "Intel Core i5-12400F")
    parts = BuildOptimizer.new(build, fixed: [fixed]).call
    assert_includes parts, fixed
    assert_operator parts.find { |part| part.category == "memory" }.memory_gb, :>=, 32
    assert_operator parts.find { |part| part.category == "storage" }.capacity_gb, :>=, 1024
    assert BuildOptimizer.power_sufficient?(parts)
  end

  test "rejects incompatible locked hardware and impossible wishes" do
    build = candidate_build(wishes: "999 ГБ ОЗУ")
    assert_raises(BuildOptimizer::NoSolution) { BuildOptimizer.new(build).call }
    build.wishes = nil
    wrong_cpu = Component.find_by!(name: "МЦСТ Эльбрус-8СВ")
    assert_raises(BuildOptimizer::NoSolution) { BuildOptimizer.new(build, fixed: [wrong_cpu]).call }
  end

  test "replaces every unlocked part when previous options are excluded" do
    build = candidate_build(budget: 500_000)
    old = BuildOptimizer.new(build).call
    fixed = old.find { |part| part.category == "cooler" }
    exclusions = old.reject { |part| part == fixed }.map(&:id)
    new_parts = BuildOptimizer.new(build, fixed: [fixed], excluded_ids: exclusions).call
    assert_includes new_parts, fixed
    assert_empty new_parts.map(&:id) & exclusions
  end

  test "knapsack agrees with exhaustive optimum on a small catalog" do
    build = candidate_build(budget: 75_000)
    Component.where(platform: ["E2K", "Threadripper"]).update_all(available: false)
    groups = BuildOptimizer::CATEGORIES.map do |category|
      chosen = Component.where(category: category, available: true).order(:price_cents).limit(2).to_a
      Component.where(category: category).where.not(id: chosen.map(&:id)).update_all(available: false)
      chosen
    end
    score = ->(parts) { parts.sum { |part| part.performance * BuildOptimizer::PURPOSE_WEIGHTS[build.purpose].fetch(part.category, 1) } }
    combinations = groups.first.product(*groups.drop(1))
    feasible = combinations.select do |parts|
      parts.sum(&:price_cents) <= build.budget_cents &&
        parts.combination(2).all? { |a, b| a.compatible_with?(b) } &&
        BuildOptimizer.power_sufficient?(parts) &&
        parts.find { |part| part.category == "cooler" }.cools?(parts.find { |part| part.category == "cpu" })
    end
    optimum = feasible.max_by { |parts| [score.call(parts), -parts.sum(&:price_cents)] }
    actual = BuildOptimizer.new(build).call
    assert_equal score.call(optimum), score.call(actual)
    assert_equal optimum.sum(&:price_cents), actual.sum(&:price_cents)
  end
end
