module ApplicationHelper
  def rubles(cents)
    number_to_currency(cents.to_i / 100.0, unit: "₽", format: "%n %u", delimiter: " ", separator: ",", precision: 0)
  end

  def platform_options
    [["x64 · универсальный ПК", "x86-64"], ["Эльбрус · E2K", "E2K"], ["Threadripper · рабочая станция", "Threadripper"]]
  end

  def component_specifications(part)
    labels = { "form_factor" => "Форм-фактор платы", "memory_slots" => "Слоты памяти", "max_memory_gb" => "Максимум ОЗУ, ГБ", "modules" => "Модулей в комплекте",
      "storage_interfaces" => "Интерфейсы накопителей", "storage_interface" => "Интерфейс накопителя", "supported_sockets" => "Крепление кулера",
      "supported_cpus" => "Поддерживаемые процессоры", "supported_forms" => "Платы для корпуса", "cooler_height_mm" => "Высота кулера, мм",
      "max_cooler_height_mm" => "Кулер до, мм", "gpu_length_mm" => "Длина видеокарты, мм", "max_gpu_length_mm" => "Видеокарта до, мм",
      "psu_length_mm" => "Длина БП, мм", "max_psu_length_mm" => "Блок питания до, мм", "recommended_psu_watts" => "Рекомендованный БП от, Вт",
      "eps_connectors" => "Разъёмы EPS питания CPU", "gpu_8pin" => "Разъёмы PCIe 8-pin", "cooling_watts" => "Заявленный отвод тепла до, Вт", "verified_on" => "Характеристики проверены" }
    part.specs.except("source_url", "catalog", "price_on_request").map { |key, value| [labels.fetch(key, key), value.is_a?(Array) ? value.join(", ") : value] }
  end

  def component_price(part)
    part.specs["price_on_request"] ? "Цена по запросу" : rubles(part.price_cents)
  end

  def manufacturer_source(part)
    value = part.specs["source_url"].to_s
    value if value.start_with?("https://")
  end
end
