class Build < ApplicationRecord
  PLATFORMS = ["x86-64", "E2K", "Threadripper"].freeze
  STATUSES = %w[draft ready archived].freeze

  belongs_to :user
  has_many :build_items, dependent: :destroy
  has_many :components, through: :build_items

  validates :name, :purpose, :platform, presence: true
  validates :platform, inclusion: { in: PLATFORMS }
  validates :status, inclusion: { in: STATUSES }
  validates :budget_cents, numericality: { only_integer: true, greater_than: 0 }

  def total_price_cents
    build_items.includes(:component).sum { |item| item.component.price_cents.to_i * item.quantity }
  end

  def remaining_budget_cents
    budget_cents.to_i - total_price_cents
  end

  def within_budget?
    remaining_budget_cents >= 0
  end

  def compatible?
    components.to_a.combination(2).all? { |left, right| left.compatible_with?(right) }
  end

  def readiness
    return :over_budget unless within_budget?
    return :incompatible unless compatible?
    return :empty if build_items.empty?

    :ready
  end

  def add_component(component, quantity: 1)
    item = build_items.find_or_initialize_by(component: component)
    item.quantity = item.new_record? ? quantity.to_i : item.quantity.to_i + quantity.to_i
    item.save
    item
  end
end
