class CompatibilityRule < ApplicationRecord
  belongs_to :component
  belongs_to :compatible_component, class_name: "Component", inverse_of: :reverse_compatibility_rules

  validates :compatible_component_id, uniqueness: { scope: :component_id }
  validate :different_components

  private

  def different_components
    return if component_id.blank? || compatible_component_id.blank?
    return unless component_id == compatible_component_id

    errors.add(:compatible_component, "должен отличаться от исходной детали")
  end
end
