require "test_helper"
require_relative "../support/configurator_catalog"

class HardwareCatalogTest < ActiveSupport::TestCase
  include ConfiguratorCatalog
  setup { load_configurator_catalog }

  test "catalog contains real brands and manufacturer sources for every imported item" do
    entries = HardwareCatalog.entries
    assert_operator entries.size, :>=, 35
    %w[Intel AMD ASUS MSI Kingston SAPPHIRE].each { |brand| assert_includes entries.pluck(:manufacturer), brand }
    entries.each do |attributes|
      assert_match %r{\Ahttps://}, attributes[:specs]["source_url"]
      refute_match /Build Wise Demo|BW-/, attributes[:name]
    end
    assert_equal 0, Component.where(manufacturer: "Build Wise Demo", available: true).count
  end

  test "repeated import preserves saved builds reviews and archives placeholder records" do
    build = candidate_build
    build.save!
    old = Component.create!(name: "Old demo CPU", manufacturer: "Build Wise Demo", category: "cpu", platform: "x86-64", price_cents: 100_00)
    item = build.build_items.create!(component: old)
    review = old.reviews.create!(user: build.user, rating: 4, body: "Сохранённый отзыв")
    count = Component.count
    load_configurator_catalog
    load_configurator_catalog
    assert_equal count, Component.count
    assert_not old.reload.available?
    assert_equal old.id, item.reload.component_id
    assert_equal "Сохранённый отзыв", review.reload.body
  end

  test "Intel and AMD builds select matching boards and memory" do
    build = candidate_build(budget: 300_000)
    ["Intel Core i5-12400F", "AMD Ryzen 5 7600"].each do |name|
      cpu = Component.find_by!(name: name)
      parts = BuildOptimizer.new(build, fixed: [cpu]).call
      assert_equal cpu.socket, parts.find { |part| part.category == "motherboard" }.socket
      assert_includes cpu.memory_type, parts.find { |part| part.category == "memory" }.memory_type
    end
  end

  test "socket memory type case dimensions and EPS mismatches are rejected" do
    intel = Component.find_by!(name: "Intel Core i5-12400F")
    amd_board = Component.find_by!(name: "ASUS TUF GAMING B650-PLUS")
    ddr4 = Component.find_by!(memory_type: "DDR4", category: "memory")
    rdimm = Component.find_by!(memory_type: "DDR5 RDIMM", category: "memory")
    tr_board = Component.find_by!(name: "ASUS Pro WS TRX50-SAGE WIFI")
    normal_case = Component.find_by!(name: "Cooler Master MasterBox NR600 (без ODD)")
    small_psu = Component.find_by!(name: "MSI MAG A550BN 550W")
    assert_not intel.compatible_with?(amd_board)
    assert_not ddr4.compatible_with?(amd_board)
    assert_not rdimm.compatible_with?(amd_board)
    assert_not tr_board.compatible_with?(normal_case)
    assert_not tr_board.compatible_with?(small_psu)
    too_tall = Component.new(category: "cooler", platform: "universal", specs: { "cooler_height_mm" => 190 })
    assert_not normal_case.compatible_with?(too_tall)
  end

  test "multi socket cooler and verified Threadripper cooling work without invented TDP" do
    cooler = Component.find_by!(name: "DeepCool AK400")
    intel = Component.find_by!(name: "Intel Core i5-12400F")
    amd = Component.find_by!(name: "AMD Ryzen 5 7600")
    tr = Component.find_by!(name: "AMD Ryzen Threadripper 7960X")
    tr_cooler = Component.find_by!(name: "Noctua NH-U14S TR5-SP6")
    assert cooler.compatible_with?(intel)
    assert cooler.compatible_with?(amd)
    assert_not cooler.compatible_with?(tr)
    assert tr_cooler.cools?(tr)
    assert_nil tr_cooler.specs["cooling_watts"]
  end
end
