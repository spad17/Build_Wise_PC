require "test_helper"

class ComponentTest < ActiveSupport::TestCase
  def component(attributes = {})
    Component.new({
      name: "Ryzen 7 7800X3D",
      manufacturer: "AMD",
      category: "cpu",
      platform: "x86-64",
      socket: "AM5",
      price_cents: 42_990_00
    }.merge(attributes))
  end

  test "validates catalog fields and non-negative price" do
    item = component(price_cents: -1)

    assert_not item.valid?
    assert item.errors[:price_cents].any?
    assert item.errors[:name].empty?
  end

  test "does not allow a duplicate manufacturer and model" do
    component.save!
    duplicate = component(name: "ryzen 7 7800x3d")

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:name], "уже существует"
  end

  test "matches platform and socket when checking compatibility" do
    cpu = component
    motherboard = component(name: "B650 Motherboard", manufacturer: "Build Wise", category: "motherboard", socket: "AM5", price_cents: 18_000_00)
    other_socket = component(name: "LGA1700 Motherboard", manufacturer: "Build Wise", category: "motherboard", socket: "LGA1700", price_cents: 20_000_00)

    assert cpu.compatible_with?(motherboard)
    assert_not cpu.compatible_with?(other_socket)
  end

  test "allows an explicit compatibility rule to override platform mismatch" do
    cpu = component
    accelerator = component(name: "E2K Accelerator", manufacturer: "Elbrus", category: "gpu", platform: "E2K", socket: nil, price_cents: 25_000_00)
    cpu.save!
    accelerator.save!
    CompatibilityRule.create!(component: cpu, compatible_component: accelerator)

    assert cpu.compatible_with?(accelerator)
  end
end
