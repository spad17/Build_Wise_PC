require_relative "catalog"
require_relative "../app/services/catalog_media"

Component.transaction do
  # Keep records referenced by saved builds/reviews, but exclude placeholders from new selection.
  Component.where(manufacturer: "Build Wise Demo").update_all(available: false)
  HardwareCatalog.entries.each do |attributes|
    part = Component.find_or_initialize_by(manufacturer: attributes[:manufacturer], name: attributes[:name])
    part.assign_attributes(attributes.merge(data_synced_at: Time.current))
    part.image_url = CatalogMedia.ensure_fallback!(part)
    part.image_credit ||= "Уникальная карточка модели Build Wise"
    part.save!
  end
end
puts "Каталог обновлён: #{HardwareCatalog.entries.size} реальных моделей. Цены ориентировочные."
