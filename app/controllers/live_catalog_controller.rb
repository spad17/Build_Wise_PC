class LiveCatalogController < ApplicationController
  def index
    @categories = Component::CATEGORY_NAMES
  end

  def data
    scope = Component.where(available: true).or(Component.where(manufacturer: "МЦСТ"))
    scope = scope.where(category: params[:category]) if Component::CATEGORIES.include?(params[:category].to_s)

    if params[:q].present?
      query = "%#{Component.sanitize_sql_like(params[:q].to_s.strip)}%"
      scope = scope.where("name LIKE :q OR manufacturer LIKE :q OR description LIKE :q", q: query)
    end

    scope = scope.order(data_synced_at: :desc, updated_at: :desc, name: :asc)
    render json: {
      generated_at: Time.current.iso8601,
      last_changed_at: scope.maximum(:data_synced_at)&.iso8601,
      total: scope.count,
      components: scope.limit(100).map { |component| component_payload(component) }
    }
    response.headers["Cache-Control"] = "no-store, max-age=0"
  end

  private

  def component_payload(component)
    {
      id: component.id,
      name: component.name,
      manufacturer: component.manufacturer,
      category: component.category,
      category_name: Component::CATEGORY_NAMES.fetch(component.category, component.category),
      platform: component.platform,
      price_cents: component.price_cents,
      price: component.specs["price_on_request"] ? "Цена по запросу" : component.price,
      performance: component.performance,
      available: component.available?,
      image_url: component.image_url.presence || "/component-images/catalog-fallback.svg",
      image_credit: component.image_credit,
      source_url: component.specs["source_url"],
      updated_at: component.data_synced_at&.iso8601 || component.updated_at.iso8601
    }
  end

  def component_price(component)
    return "Цена по запросу" if component.specs["price_on_request"]

    helpers.number_to_currency(component.price, unit: "₽", format: "%n %u", delimiter: " ", precision: 0)
  end
end
