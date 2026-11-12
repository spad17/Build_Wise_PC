require "digest"
require "fileutils"

class CatalogMedia
  PALETTE = %w[#1f5c49 #263a75 #5c3b72 #7a4c25 #225f71 #5e6125 #3f4a4b #75435a].freeze

  def self.ensure_fallback!(component)
    return component.image_url if component.image_url.to_s.start_with?("http", "/component-images/")

    slug = slug_for(component)
    relative_path = "/component-images/catalog/#{slug}.svg"
    absolute_path = Rails.root.join("public", relative_path.delete_prefix("/"))
    FileUtils.mkdir_p(absolute_path.dirname)
    File.write(absolute_path, svg_for(component)) unless absolute_path.exist?
    relative_path
  end

  def self.slug_for(component)
    digest = Digest::SHA1.hexdigest("#{component.manufacturer}-#{component.name}")[0, 12]
    "#{component.category}-#{digest}"
  end

  def self.svg_for(component)
    safe_name = component.name.to_s.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;")
    safe_brand = component.manufacturer.to_s.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;")
    color = PALETTE[Digest::SHA1.hexdigest(component.name.to_s).to_i(16) % PALETTE.length]

    <<~SVG
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 960 600" role="img" aria-labelledby="title">
        <title id="title">#{safe_brand} #{safe_name}</title>
        <defs><linearGradient id="bg" x1="0" y1="0" x2="1" y2="1"><stop stop-color="#{color}"/><stop offset="1" stop-color="#101917"/></linearGradient></defs>
        <rect width="960" height="600" rx="34" fill="url(#bg)"/>
        <circle cx="790" cy="120" r="170" fill="none" stroke="#fff" stroke-opacity=".2" stroke-width="3"/>
        <rect x="90" y="118" width="780" height="300" rx="24" fill="#fff" fill-opacity=".1" stroke="#fff" stroke-opacity=".34" stroke-width="3"/>
        <path d="M130 174h210M130 200h132" stroke="#fff" stroke-opacity=".66" stroke-width="10" stroke-linecap="round"/>
        <text x="130" y="292" fill="#fff" font-family="Arial, sans-serif" font-size="34" font-weight="700">#{safe_name}</text>
        <text x="130" y="340" fill="#fff" fill-opacity=".78" font-family="Arial, sans-serif" font-size="20" letter-spacing="4">#{safe_brand.upcase} · BUILD / WISE</text>
        <text x="130" y="520" fill="#fff" fill-opacity=".62" font-family="Arial, sans-serif" font-size="17">Уникальная карточка модели каталога</text>
      </svg>
    SVG
  end
end
