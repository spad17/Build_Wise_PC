require_relative "catalog"

Component.transaction do
  # Keep records referenced by saved builds/reviews, but exclude placeholders from new selection.
  Component.where(manufacturer: "Build Wise Demo").update_all(available: false)
  HardwareCatalog.entries.each do |attributes|
    part = Component.find_or_initialize_by(manufacturer: attributes[:manufacturer], name: attributes[:name])
    part.update!(attributes)
  end
end
puts "Каталог обновлён: #{HardwareCatalog.entries.size} реальных моделей. Цены ориентировочные."
