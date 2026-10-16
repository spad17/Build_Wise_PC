class BuildItem < ApplicationRecord
  belongs_to :build
  belongs_to :component

  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :component_id, uniqueness: { scope: :build_id }
  validate :component_is_compatible_with_build

  def line_total_cents
    component.price_cents.to_i * quantity.to_i
  end

  private

  def component_is_compatible_with_build
    return if build.blank? || component.blank?

    unless component.platform == "universal" || component.platform == build.platform
      errors.add(:component, "не соответствует платформе сборки")
      return
    end

    existing_components = build.components.to_a.reject { |existing| existing.id == component.id }
    incompatible = existing_components.find { |existing| !existing.compatible_with?(component) }
    errors.add(:component, "несовместим с уже выбранными деталями") if incompatible
  end
end
