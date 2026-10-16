class Component < ApplicationRecord
  CATEGORIES = %w[cpu gpu motherboard memory storage psu case cooler].freeze
  PLATFORMS = ["x86-64", "E2K", "Threadripper", "universal"].freeze

  has_many :build_items, dependent: :restrict_with_error
  has_many :builds, through: :build_items
  has_many :compatibility_rules, dependent: :destroy
  has_many :compatible_components, through: :compatibility_rules
  has_many :reverse_compatibility_rules,
           class_name: "CompatibilityRule",
           foreign_key: :compatible_component_id,
           dependent: :destroy,
           inverse_of: :compatible_component

  validates :name, :manufacturer, :category, :platform, presence: true
  validates :category, inclusion: { in: CATEGORIES }
  validates :platform, inclusion: { in: PLATFORMS }
  validates :price_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :power_watts, :memory_gb, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :name, uniqueness: { scope: :manufacturer, case_sensitive: false }

  def price
    price_cents.to_i / 100.0
  end

  def compatible_with?(other)
    return false unless other.is_a?(Component)
    return true if explicit_compatibility_with?(other)
    return false unless platforms_compatible_with?(other)
    return true if socket.blank? || other.socket.blank?

    socket.casecmp?(other.socket)
  end

  private

  def explicit_compatibility_with?(other)
    compatible_components.exists?(id: other.id) ||
      other.compatible_components.exists?(id: id)
  end

  def platforms_compatible_with?(other)
    platform == "universal" || other.platform == "universal" || platform == other.platform
  end
end
