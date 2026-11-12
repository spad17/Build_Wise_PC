# Specifications: manufacturer pages linked on every entry (checked 2026-10-30).
# RUB prices and utility points are editorial estimates, not live store offers or benchmarks.
require "digest"

module HardwareCatalog
  IMAGE_OVERRIDES = {
    "AMD Ryzen 7 7800X3D" => [
      "https://www.amd.com/content/dam/amd/en/images/products/processors/ryzen/2505503-ryzen-7-7800x3d-og.jpg",
      "Официальное изображение AMD Ryzen 7 7800X3D"
    ],
    "AMD Radeon RX 7800 XT 16 ГБ (Reference)" => [
      "https://d1io3yog0oux5.cloudfront.net/_0627aa6638dff44d3ac521304b25e136/amd/db/834/7308/social_image_resized.jpg",
      "Официальное изображение AMD Radeon RX 7800 XT"
    ],
    "ASUS Dual GeForce RTX 4060 OC 8 ГБ" => [
      "https://press.asus.com/assets/w_640%2Ch_640/32e0e823-60b0-4e89-8b05-5cfbdd070fd8/DUAL-RTX4060-O8G_Box%2BVGA%2BNV.png",
      "Официальное изображение ASUS Dual GeForce RTX 4060"
    ],
    "MSI GeForce RTX 4070 SUPER 12G VENTUS 2X WHITE" => [
      "https://storage-asset.msi.com/global/picture/product/product_17046997993c786b97a32cd491dde4c5b09ab12cdb.webp",
      "Официальное изображение MSI GeForce RTX 4070 SUPER"
    ],
    "Kingston FURY Beast DDR5 32 ГБ (2×16) KF560C36BBEK2-32" => [
      "https://cdn.shopify.com/s/files/1/0518/5073/9904/files/ktc-fury-memory-beast-ddr5-etail-kf-7-1350x550_56860bc5-a066-44cb-961e-16a63934bce9.jpg?v=1680114651",
      "Официальное изображение Kingston FURY Beast DDR5"
    ],
    "Kingston FURY Beast DDR4 16 ГБ (2×8) KF432C16BBK2/16" => [
      "https://i.ebayimg.com/images/g/KusAAeSw3mtpvx8S/s-l1200.jpg",
      "Фото страницы товара Kingston FURY Beast DDR4 16 ГБ"
    ],
    "Kingston FURY Beast DDR4 32 ГБ (2×16) KF432C16BBK2/32" => [
      "https://i.ebayimg.com/images/g/DMcAAeSwxJJquOIp/s-l960.jpg",
      "Фото страницы товара Kingston FURY Beast DDR4 32 ГБ"
    ],
    "Kingston FURY Beast DDR5 64 ГБ (2×32) KF560C36BBEK2-64" => [
      "https://easypc.com.ph/cdn/shop/files/Kingston_Fury_Beast_64gb_KF556C40BBK2-64_2x32_5600MT_s_Ddr5_CL40_Memory_Black_Intel_XMP_1200x1200.png?v=1707891000",
      "Фото страницы товара Kingston FURY Beast DDR5 64 ГБ"
    ],
    "Kingston FURY Renegade Pro DDR5 RDIMM 128 ГБ (4×32) KF560R32RBK4-128" => [
      "https://media.spdigital.cl/thumbnails/products/1734697908557-a5b2371709f2c80ffadc92587bde6192_083de734_thumbnail_4096.jpg",
      "Фото страницы товара Kingston FURY Renegade Pro 128 ГБ"
    ],
    "Corsair RM750e 750W" => [
      "https://assets.corsair.com/image/upload/c_scale,q_auto,w_1200/products/rme-series-2025/Gallery/CP-9020295-NA_01.png",
      "Официальное изображение Corsair RM750e"
    ],
    "Corsair RM1000e 1000W" => [
      "https://res.cloudinary.com/corsair-pwa/image/upload/c_scale,q_auto,w_1200/v1680126573/products/Power-Supply-Units/base-rme-series-2023-psu-config/Gallery/1000W/RM1000e_01.png",
      "Официальное изображение Corsair RM1000e"
    ],
    "Fractal Design Define 7 XL Black Solid" => [
      "https://cdn3.centrecom.com.au/images/upload/0156263_0.jpeg",
      "Фото страницы товара Fractal Design Define 7 XL Black Solid"
    ],
    "DeepCool AK400" => [
      "https://fly.bg/uploads/products/as/deepcool_ak400_cpu_air_cooler_1x120mm_pwm_fan_tdp_gwx9n.jpg",
      "Фото страницы товара DeepCool AK400"
    ],
    "DeepCool AK620" => [
      "https://image.citycenter.jo/cache/catalog/12022/AK6201-1200x1200.jpg",
      "Фото страницы товара DeepCool AK620"
    ],
    "Cooler Master MasterBox NR600 (без ODD)" => [
      "https://media.topachat.com/media/s1000/619e435aa5c58356de783dfb.webp",
      "Фото страницы товара Cooler Master MasterBox NR600"
    ],
    "Corsair 4000D AIRFLOW" => [
      "https://www.invidcomputers.com/images/000000000041309044388-base-4000d-airflow-config-Gallery-4000D-AF-BLACK-01.jpg",
      "Фото страницы товара Corsair 4000D AIRFLOW"
    ],
    "MSI MAG A550BN 550W" => [
      "https://storage-asset.msi.com/global/picture/image/feature/power/Reseller/MAG-A550BN/MAG-A550BN-kv.jpg",
      "Официальное изображение MSI MAG A550BN"
    ],
    "Noctua NH-U14S TR5-SP6" => [
      "https://www.jib.co.th/img_master/product/original/2024032715124766473_3.jpg",
      "Фото страницы товара Noctua NH-U14S TR5-SP6"
    ],
    "Intel Core i3-12100F" => [
      "https://plazait.co.id/uploads/products/intel-core-i3-12100f.webp",
      "Фото страницы товара Intel Core i3-12100F"
    ],
    "AMD Ryzen 5 7600" => [
      "https://www.trippodo.com/730901-medium_default/amd-ryzen-5-7600-processor-38-ghz-32-mb-l2-l3.jpg",
      "Фото страницы товара AMD Ryzen 5 7600"
    ],
    "AMD Ryzen 7 7700" => [
      "https://images7.kabum.com.br/produtos/fotos/sync_mirakl/1059147/xlarge/Processador-Amd-Ryzen-7-7700-Socket-Am5-5-3ghz-40mb_1784294625.jpg",
      "Фото страницы товара AMD Ryzen 7 7700"
    ],
    "ASUS PRIME H610M-K D4" => [
      "https://cdn.inet.se/product/1600x900/1903717_0.jpg",
      "Фото страницы товара ASUS PRIME H610M-K D4"
    ],
    "ASUS PRIME B660M-A D4" => [
      "https://media.ldlc.com/r1600/ld/products/00/05/91/68/LD0005916829_1.jpg",
      "Фото страницы товара ASUS PRIME B660M-A D4"
    ],
    "ASUS TUF GAMING B650-PLUS" => [
      "https://cdn.awsli.com.br/2500x2500/2557/2557636/produto/207520426/p049032_1-vjbufk.jpg",
      "Фото страницы товара ASUS TUF GAMING B650-PLUS"
    ],
    "ASUS Pro WS TRX50-SAGE WIFI" => [
      "https://media.solotodo.com/media/products/1881561_picture_1715601110.jpg",
      "Фото страницы товара ASUS Pro WS TRX50-SAGE WIFI"
    ],
    "Intel Core i5-12400F" => [
      "https://bizweb.dktcdn.net/thumb/1024x1024/100/357/448/products/cpu-intel-i5-12400f-alder-lake.jpg?v=1645495434170",
      "Фото страницы товара Intel Core i5-12400F"
    ],
    "AMD Ryzen Threadripper 7960X" => [
      "https://pisces.bbystatic.com/image2/BestBuy_US/images/products/56964ac9-7d74-42c6-a525-1ff9ce411de0.jpg%3BmaxHeight%3D1920%3BmaxWidth%3D900?format=webp",
      "Фото упаковки AMD Ryzen Threadripper 7960X"
    ],
    "AMD Ryzen Threadripper 7970X" => [
      "https://cdn.ibertronica.es/product/MI100-100001351WOF_00001.jpeg",
      "Фото страницы товара AMD Ryzen Threadripper 7970X"
    ],
    "AMD Ryzen Threadripper 7980X" => [
      "https://cdn.ibertronica.es/product/MI100-000001350_00001.jpeg",
      "Фото страницы товара AMD Ryzen Threadripper 7980X"
    ],
    "SAPPHIRE PULSE Radeon RX 6600 8 ГБ" => [
      "https://www.fgtec.com.br/media/catalog/product/cache/6630b9e112ee13f7d501bef37f6e88ec/d/e/de77cc9367875762cbd497b4c3f5eef9_1.webp",
      "Фото страницы товара SAPPHIRE PULSE Radeon RX 6600"
    ],
    "Kingston A400 960 ГБ SA400S37/960G" => [
      "https://www.infotec.com.pe/29924-thickbox_default/disco-solido-ssd-kingston-960gb-sa400s37960g-blister.jpg",
      "Фото страницы товара Kingston A400 960 ГБ"
    ],
    "Kingston KC3000 4096 ГБ SKC3000D/4096G" => [
      "https://media.kingston.com/kingston/product/ktc-product-ssd-kc3000-4096gb-3-sm.jpg",
      "Официальное изображение Kingston KC3000 4096 ГБ"
    ],
    "Kingston KC3000 1024 ГБ SKC3000S/1024G" => [
      "https://m.kak.cz/foto/kingston/325592/big/1024gb-ssd-kc3000-kingston-m2-pcie-40-nvme-1.jpg",
      "Фото страницы товара Kingston KC3000 1024 ГБ"
    ],
    "Kingston KC3000 2048 ГБ SKC3000D/2048G" => [
      "https://product.hstatic.net/200000420363/product/kingston-kc3000-2tb-m.2-nvme-pcie-4.0_7b7665eede184e989acd9bbae9a55a44_master.png",
      "Фото страницы товара Kingston KC3000 2048 ГБ"
    ],
    "Kingston A400 480 ГБ SA400S37/480G" => [
      "https://cf.shopee.com.my/file/627d36409e60693775b1974e05dd1966",
      "Фото страницы товара Kingston A400 480 ГБ"
    ],
    "МЦСТ Эльбрус-8СВ" => [
      "https://tehnoomsk.ru/wp-content/uploads/2018/09/elbrus-8sv_elbrus-8s2_russian_cpu_0.jpg",
      "Фото процессора МЦСТ Эльбрус-8СВ"
    ],
    "МЦСТ 1Э8СВ-uATX (модуль с Эльбрус-8СВ)" => [
      "/component-images/catalog/mcst-1e8sv-uatx.png",
      "Фото платы МЦСТ из каталога вычислительных модулей"
    ]
  }.freeze

  def self.fallback_image(name, category, manufacturer)
    digest = Digest::SHA1.hexdigest("#{manufacturer}-#{name}")[0, 12]
    "/component-images/catalog/#{category}-#{digest}.svg"
  end

  def self.entries
    rows = []
    add = lambda do |name, brand, category, price, points, source, attributes = {}|
      specs = attributes.delete(:specs) || {}
      image_url, image_credit = IMAGE_OVERRIDES[name] || [fallback_image(name, category, brand), "Уникальная карточка модели Build Wise"]
      rows << { name: name, manufacturer: brand, category: category, platform: "universal",
        price_cents: price * 100, performance: points, available: true, quiet: false,
        socket: nil, memory_type: nil, memory_gb: nil, capacity_gb: nil, power_watts: nil,
        description: "#{name}. Основные характеристики сверены со спецификацией производителя. Цена — ориентир для расчёта бюджета, наличие в магазинах не отслеживается.",
        image_url: image_url, image_credit: image_credit,
        specs: specs.merge("source_url" => source, "verified_on" => "2026-10-30", "catalog" => "real-hardware-v1") }.merge(attributes)
    end
    intel_i3 = "https://www.intel.com/content/www/us/en/products/sku/132223/intel-core-i312100f-processor-12m-cache-up-to-4-30-ghz/specifications.html"
    intel_i5 = "https://www.intel.com/content/www/us/en/products/sku/134587/intel-core-i512400f-processor-18m-cache-up-to-4-40-ghz/specifications.html"
    amd_7000 = "https://www.amd.com/en/newsroom/press-releases/2023-1-4-amd-extends-its-leadership-with-the-introduction-o.html"
    amd_tr = "https://www.amd.com/content/dam/amd/en/documents/partner-hub/threadripper/ryzen-threadripper-pro-7000-series-qrg.pdf"
    [
      ["Intel Core i3-12100F", "Intel", 7000, 32, "LGA1700", "DDR4", 89, 4, 8, intel_i3],
      ["Intel Core i5-12400F", "Intel", 11000, 48, "LGA1700", "DDR4", 117, 6, 12, intel_i5],
      ["AMD Ryzen 5 7600", "AMD", 18000, 62, "AM5", "DDR5", 88, 6, 12, amd_7000],
      ["AMD Ryzen 7 7700", "AMD", 26000, 73, "AM5", "DDR5", 88, 8, 16, amd_7000],
      ["AMD Ryzen 7 7800X3D", "AMD", 39000, 90, "AM5", "DDR5", 162, 8, 16, "https://www.amd.com/en/products/processors/desktops/ryzen/7000-series/amd-ryzen-7-7800X3d.html"],
      ["AMD Ryzen Threadripper 7960X", "AMD", 170000, 130, "sTR5", "DDR5 RDIMM", 350, 24, 48, amd_tr],
      ["AMD Ryzen Threadripper 7970X", "AMD", 260000, 160, "sTR5", "DDR5 RDIMM", 350, 32, 64, amd_tr],
      ["AMD Ryzen Threadripper 7980X", "AMD", 490000, 210, "sTR5", "DDR5 RDIMM", 350, 64, 128, amd_tr]
    ].each do |name, brand, price, points, socket, memory, watts, cores, threads, source|
      add.call(name, brand, "cpu", price, points, source, platform: socket == "sTR5" ? "Threadripper" : "x86-64", socket: socket,
        memory_type: brand == "Intel" ? "DDR4 / DDR5" : memory, power_watts: watts, specs: { "Ядра / потоки" => "#{cores} / #{threads}", "Расчёт питания" => "Консервативный лимит для подбора; не измеренное потребление" })
    end
    [
      ["ASUS PRIME H610M-K D4", 6500, 10, "LGA1700", "DDR4", "mATX", 2, 64, "https://www.asus.com/au/motherboards-components/motherboards/prime/prime-h610m-k-d4/techspec/"],
      ["ASUS PRIME B660M-A D4", 11000, 18, "LGA1700", "DDR4", "mATX", 4, 128, "https://www.asus.com/motherboards-components/motherboards/prime/prime-b660m-a-d4/techspec/"],
      ["ASUS TUF GAMING B650-PLUS", 21000, 23, "AM5", "DDR5", "ATX", 4, 128, "https://www.asus.com/uk/motherboards-components/motherboards/tuf-gaming/tuf-gaming-b650-plus/techspec/"],
      ["ASUS Pro WS TRX50-SAGE WIFI", 115000, 32, "sTR5", "DDR5 RDIMM", "SSI-CEB", 4, 512, "https://www.asus.com/us/motherboards-components/motherboards/workstation/pro-ws-trx50-sage-wifi/techspec/"]
    ].each do |name, price, points, socket, memory, form, slots, max_memory, source|
      add.call(name, "ASUS", "motherboard", price, points, source, platform: socket == "sTR5" ? "Threadripper" : "x86-64", socket: socket,
        memory_type: memory, power_watts: 40, specs: { "form_factor" => form, "memory_slots" => slots, "max_memory_gb" => max_memory,
        "storage_interfaces" => %w[SATA NVMe], "eps_connectors" => socket == "sTR5" ? 2 : 1,
        "Примечание" => "Проверьте версию BIOS и список QVL перед покупкой. Для TRX50 подключение дополнительных разъёмов питания — по руководству ASUS." })
    end
    [
      ["Kingston FURY Beast DDR4 16 ГБ (2×8) KF432C16BBK2/16", "DDR4", 16, 2, 4000, 12, "https://www.kingston.com/datasheets/KF432C16BBK2_16.pdf"],
      ["Kingston FURY Beast DDR4 32 ГБ (2×16) KF432C16BBK2/32", "DDR4", 32, 2, 7000, 24, "https://www.kingston.com/datasheets/KF432C16BBK2_32.pdf"],
      ["Kingston FURY Beast DDR5 32 ГБ (2×16) KF560C36BBEK2-32", "DDR5", 32, 2, 12000, 28, "https://www.kingston.com/datasheets/KF560C36BBEK2-32.pdf"],
      ["Kingston FURY Beast DDR5 64 ГБ (2×32) KF560C36BBEK2-64", "DDR5", 64, 2, 23000, 42, "https://www.kingston.com/datasheets/KF560C36BBEK2-64.pdf"],
      ["Kingston FURY Renegade Pro DDR5 RDIMM 128 ГБ (4×32) KF560R32RBK4-128", "DDR5 RDIMM", 128, 4, 85000, 65, "https://www.kingston.com/datasheets/KF560R32RBK4-128.pdf"]
    ].each do |name, type, gb, count, price, points, source|
      add.call(name, "Kingston", "memory", price, points, source, memory_type: type, memory_gb: gb, power_watts: count * 4,
        specs: { "modules" => count, "Высота, мм" => type == "DDR4" ? 34 : (type == "DDR5" ? 34.9 : 31.25),
          "Режим частоты" => "XMP/EXPO требует включения и поддержки CPU/BIOS; по умолчанию используется JEDEC" })
    end
    [
      ["SAPPHIRE PULSE Radeon RX 6600 8 ГБ", "SAPPHIRE", 20000, 44, 8, 140, 500, 193, "https://www.sapphiretech.com/en/consumer/pulse-radeon-rx-6600-8g-gddr6"],
      ["ASUS Dual GeForce RTX 4060 OC 8 ГБ", "ASUS", 32000, 60, 8, 120, 550, 227.2, "https://www.asus.com/uk/motherboards-components/graphics-cards/dual/dual-rtx4060-o8g/techspec/"],
      ["MSI GeForce RTX 4070 SUPER 12G VENTUS 2X WHITE", "MSI", 68000, 100, 12, 220, 650, 242, "https://www.msi.com/Graphics-Card/GeForce-RTX-4070-SUPER-12G-VENTUS-2X-WHITE/Specification"],
      ["AMD Radeon RX 7800 XT 16 ГБ (Reference)", "AMD", 56000, 92, 16, 263, 700, 267, "https://ir.amd.com/news-events/press-releases/detail/1153/new-amd-radeon-rx-7800-xt-and-radeon-rx-7700-xt-graphics-cards-deliver-high-performance-visually-stunning-1440p-gaming-experiences-and-superior-performance-per-dollar"]
    ].each do |name, brand, price, points, gb, watts, psu, length, source|
      add.call(name, brand, "gpu", price, points, source, platform: "x86-64", memory_gb: gb, memory_type: name.include?("4070") ? "GDDR6X" : "GDDR6", power_watts: watts,
        specs: { "gpu_length_mm" => length, "recommended_psu_watts" => psu, "gpu_8pin" => name.include?("7800") ? 2 : 1,
          "Разъём питания" => name.include?("4070") ? "16-pin, используйте штатный кабель/адаптер производителя" : "PCIe 8-pin",
          "Поддержка платформ" => "x64 и Threadripper. Совместимость драйверов с E2K не подтверждена." })
    end
    [
      ["Kingston A400 480 ГБ SA400S37/480G", 480, "SATA", 3500, 8, "https://www.kingston.com/unitedkingdom/en/ssd/a400-solid-state-drive"],
      ["Kingston A400 960 ГБ SA400S37/960G", 960, "SATA", 6000, 14, "https://www.kingston.com/unitedkingdom/en/ssd/a400-solid-state-drive"],
      ["Kingston KC3000 1024 ГБ SKC3000S/1024G", 1024, "NVMe", 10000, 25, "https://www.kingston.com/datasheets/KC3000_us.pdf"],
      ["Kingston KC3000 2048 ГБ SKC3000D/2048G", 2048, "NVMe", 18000, 38, "https://www.kingston.com/datasheets/KC3000_us.pdf"],
      ["Kingston KC3000 4096 ГБ SKC3000D/4096G", 4096, "NVMe", 35000, 50, "https://www.kingston.com/datasheets/KC3000_us.pdf"]
    ].each do |name, gb, interface, price, points, source|
      add.call(name, "Kingston", "storage", price, points, source, capacity_gb: gb, power_watts: 11, quiet: true, specs: { "storage_interface" => interface })
    end
    [
      ["MSI MAG A550BN 550W", "MSI", 550, 4500, 8, false, 140, 1, 2, "https://us.msi.com/Power-Supply/MAG-A550BN/Specification"],
      ["Corsair RM750e 750W", "Corsair", 750, 12000, 12, true, 140, 2, 3, "https://www.corsair.com/us/en/p/psu/cp-9020295-na/rme-series-rm750e-fully-modular-low-noise-atx-power-supply-cp-9020295-na"],
      ["Corsair RM1000e 1000W", "Corsair", 1000, 19000, 16, true, 140, 2, 3, "https://www.corsair.com/us/en/p/psu/cp-9020264-na/rme-series-rm1000e-fully-modular-low-noise-atx-power-supply-cp-9020264-na"]
    ].each do |name, brand, watts, price, points, quiet, length, eps, pcie, source|
      add.call(name, brand, "psu", price, points, source, power_watts: watts, quiet: quiet,
        specs: { "psu_length_mm" => length, "eps_connectors" => eps, "gpu_8pin" => pcie, "Форм-фактор" => "ATX" })
    end
    [
      ["Cooler Master MasterBox NR600 (без ODD)", "Cooler Master", 6500, 8, false, 166, 410, 160, %w[mATX ATX], "https://www.coolermaster.com/en-global/products/MCB-NR600-KGNN-S00.html"],
      ["Corsair 4000D AIRFLOW", "Corsair", 11000, 12, false, 170, 360, 180, %w[mATX ATX], "https://assets.corsair.com/image/upload/v1684779868/corsairmedia/sys_master/productcontent/WW_4000D_4000D_Airflow_QSG_AB.pdf"],
      ["Fractal Design Define 7 XL Black Solid", "Fractal Design", 27000, 18, true, 185, 340, 250, %w[mATX ATX SSI-CEB SSI-EEB], "https://www.fractal-design.com/products/cases/define/define-7-xl/"]
    ].each do |name, brand, price, points, quiet, height, gpu, psu, forms, source|
      add.call(name, brand, "case", price, points, source, power_watts: 10, quiet: quiet,
        specs: { "supported_forms" => forms, "max_cooler_height_mm" => height, "max_gpu_length_mm" => gpu, "max_psu_length_mm" => psu })
    end
    [
      ["DeepCool AK400", 2800, 10, 155, 220, "https://uk.deepcool.com/products/Cooling/cpuaircoolers/AK400-Performance-CPU-Cooler-1700-AM5/2021/15343.shtml"],
      ["DeepCool AK620", 6500, 20, 160, 260, "https://www.deepcool.com/products/Cooling/cpuaircoolers/AK620-High-Performance-CPU-Cooler-1700-AM5/2021/13067.shtml"]
    ].each do |name, price, points, height, cooling, source|
      add.call(name, "DeepCool", "cooler", price, points, source, platform: "x86-64", quiet: true, power_watts: 3,
        specs: { "supported_sockets" => %w[LGA1700 AM4 AM5], "cooler_height_mm" => height, "cooling_watts" => cooling })
    end
    add.call("Noctua NH-U14S TR5-SP6", "Noctua", "cooler", 19000, 24, "https://www.noctua.at/en/products/nh-u14s-tr5-sp6/compatibility/cpus?socketId=39&vendorId=2",
      platform: "Threadripper", socket: "sTR5", quiet: true, power_watts: 4,
      specs: { "supported_sockets" => ["sTR5"], "cooler_height_mm" => 165,
        "supported_cpus" => ["AMD Ryzen Threadripper 7960X", "AMD Ryzen Threadripper 7970X", "AMD Ryzen Threadripper 7980X"],
        "Охлаждение" => "Совместимость CPU подтверждена Noctua. NSPR 179 не является мощностью в ваттах." })
    add.call("МЦСТ Эльбрус-8СВ", "МЦСТ", "cpu", 180000, 35,
      "https://www.mcst.ru/files/60868d/06dece/61386c/f5f2c1/bocharov_n.a._zuev_a.g._slavin_o.a._proizvoditelnost_mikroprotsessora_elbrus-8sv_dlya_resheniya_zadach_tehnicheskogo_zreniya_v_usloviyah_ogranichenij_energopotrebleniya_.pdf",
      platform: "E2K", available: false, power_watts: 90, specs: { "price_on_request" => true, "Ядра" => 8, "Статус" => "Поставка и комплектность по запросу. Автоподбор отключён до подтверждения охлаждения и периферии." })
    add.call("МЦСТ 1Э8СВ-uATX (модуль с Эльбрус-8СВ)", "МЦСТ", "motherboard", 350000, 12,
      "https://www.mcst.ru/1e8cb-uatx_tvgi.469555.483", platform: "E2K", available: false, memory_type: "DDR4 RDIMM ECC",
      specs: { "price_on_request" => true, "form_factor" => "mATX", "Комплектность" => "Модуль уже содержит CPU. Не суммируется с ценой отдельного процессора; заказ через поставщика." })
    rows
  end
end
