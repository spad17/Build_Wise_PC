class Component < ApplicationRecord
  CATEGORIES = %w[cpu gpu motherboard memory storage psu case cooler].freeze
  CATEGORY_NAMES = { "cpu" => "Процессор", "motherboard" => "Материнская плата", "memory" => "Оперативная память", "gpu" => "Видеокарта", "storage" => "Накопитель", "psu" => "Блок питания", "case" => "Корпус", "cooler" => "Охлаждение" }.freeze
  PLATFORMS = ["x86-64", "E2K", "Threadripper", "universal"].freeze

  has_many :build_items, dependent: :restrict_with_error
  has_many :reviews, dependent: :destroy
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

  scope :for_platform, ->(platform) {
    base = where(platform: [platform, "universal"])
    platform == "Threadripper" ? base.or(where(category: "gpu", platform: "x86-64")) : base
  }

  def supports_platform?(target)
    [target, "universal"].include?(platform) || (target == "Threadripper" && category == "gpu" && platform == "x86-64")
  end

  def cools?(cpu)
    return false unless category == "cooler" && cpu&.category == "cpu"
    if specs["supported_cpus"].present?
      specs["supported_cpus"].include?(cpu.name)
    else
      specs.fetch("cooling_watts", 0).to_i >= cpu.power_watts.to_i
    end
  end

  def compatible_with?(other)
    return false unless other.is_a?(Component)
    return true if explicit_compatibility_with?(other)
    return false unless platforms_compatible_with?(other)
    if [category, other.category].sort == %w[memory motherboard]
      return false if memory_type.present? && other.memory_type.present? && memory_type != other.memory_type
      board, ram = category == "motherboard" ? [self, other] : [other, self]
      return false if board.specs["memory_slots"] && ram.specs.fetch("modules", 1).to_i > board.specs["memory_slots"].to_i
      return false if board.specs["max_memory_gb"] && ram.memory_gb.to_i > board.specs["max_memory_gb"].to_i
    end
    cooler, mounted = category == "cooler" ? [self, other] : [other, self]
    if cooler.category == "cooler" && %w[cpu motherboard].include?(mounted.category) && cooler.specs["supported_sockets"].present?
      return false unless cooler.specs["supported_sockets"].include?(mounted.socket)
    end
    chassis, part = category == "case" ? [self, other] : [other, self]
    if chassis.category == "case"
      if part.category == "motherboard" && chassis.specs["supported_forms"] && part.specs["form_factor"]
        return false unless chassis.specs["supported_forms"].include?(part.specs["form_factor"])
      end
      { "cooler" => ["cooler_height_mm", "max_cooler_height_mm"], "gpu" => ["gpu_length_mm", "max_gpu_length_mm"], "psu" => ["psu_length_mm", "max_psu_length_mm"] }.each do |type, (size, limit)|
        return false if part.category == type && part.specs[size] && chassis.specs[limit] && part.specs[size].to_f > chassis.specs[limit].to_f
      end
    end
    psu, powered = category == "psu" ? [self, other] : [other, self]
    if psu.category == "psu"
      return false if powered.category == "gpu" && psu.power_watts.to_i < powered.specs.fetch("recommended_psu_watts", 0).to_i
      if powered.category == "motherboard" && powered.specs["eps_connectors"] && psu.specs["eps_connectors"]
        return false if powered.specs["eps_connectors"].to_i > psu.specs["eps_connectors"].to_i
      end
    end
    return true if socket.blank? || other.socket.blank?

    socket.casecmp?(other.socket)
  end

  private

  def explicit_compatibility_with?(other)
    explicitly_lists?(other) || other.send(:explicitly_lists?, self)
  end

  def explicitly_lists?(other)
    if association(:compatible_components).loaded?
      compatible_components.any? { |part| part.id == other.id }
    else
      compatible_components.exists?(id: other.id)
    end
  end

  def platforms_compatible_with?(other)
    platform == "universal" || other.platform == "universal" || platform == other.platform ||
      (category == "gpu" && platform == "x86-64" && other.platform == "Threadripper") ||
      (other.category == "gpu" && other.platform == "x86-64" && platform == "Threadripper")
  end
end
