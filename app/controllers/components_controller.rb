class ComponentsController < ApplicationController
  def index
    @components = Component.where(available: true).or(Component.where(manufacturer: "МЦСТ")).order(:category, :price_cents)
    @manufacturers = @components.distinct.pluck(:manufacturer).sort
    @components = @components.where(manufacturer: params[:manufacturer]) if params[:manufacturer].present?
    @components = @components.where(category: params[:category]) if Component::CATEGORIES.include?(params[:category])
    @components = @components.for_platform(params[:platform]) if Build::PLATFORMS.include?(params[:platform])
    if params[:q].present?
      query = "%#{Component.sanitize_sql_like(params[:q].to_s.strip)}%"
      @components = @components.where("name LIKE :q OR manufacturer LIKE :q OR description LIKE :q", q: query)
    end
    @components = @components.where("price_cents <= ?", params[:max_price].to_i * 100) if params[:max_price].present?
    @build = current_user.builds.find(params[:build_id]) if logged_in? && params[:build_id].present?
  end

  def show
    @component = Component.find(params[:id])
    @reviews = @component.reviews.includes(:user).order(created_at: :desc)
    @review = logged_in? ? (@component.reviews.find_by(user: current_user) || @component.reviews.new) : nil
    @build = current_user.builds.find(params[:build_id]) if logged_in? && params[:build_id].present?
    render layout: false if params[:modal] == "1"
  end
end
