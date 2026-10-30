class BuildsController < ApplicationController
  before_action :require_login
  before_action :set_build, only: %i[show destroy optimize replace_component]

  def index
    @builds = current_user.builds.includes(build_items: :component).order(created_at: :desc)
  end

  def new
    @build = current_user.builds.new(name: "Мой новый ПК", purpose: "Игры", platform: "x86-64", budget_cents: 100_000_00)
  end

  def create
    @build = current_user.builds.new(build_params)
    @budget_rubles = params.dig(:build, :budget_rubles)
    unless valid_budget?(@budget_rubles)
      @build.errors.add(:base, "Бюджет должен быть целым числом от 10 000 до 5 000 000 ₽.")
      return render :new, status: :unprocessable_entity
    end
    @build.budget_cents = @budget_rubles.to_i * 100
    return render(:new, status: :unprocessable_entity) unless @build.valid?
    parts = BuildOptimizer.new(@build).call
    Build.transaction do
      @build.save!
      @build.replace_configuration!(parts)
    end
    redirect_to @build, notice: "Сборка готова и сохранена. Вы можете заменить детали или пересобрать ПК."
  rescue BuildOptimizer::NoSolution => error
    @build.errors.add(:base, error.message)
    render :new, status: :unprocessable_entity
  end

  def show
    @items = @build.build_items.includes(:component).to_a.sort_by { |item| BuildOptimizer::CATEGORIES.index(item.component.category) || 99 }
    @preferences = BuildOptimizer.parse_wishes(@build.wishes)
  end

  def optimize
    locked_ids = Array(params[:locked_ids]).map(&:to_i)
    old_items = @build.build_items.includes(:component).to_a
    fixed = old_items.select { |item| locked_ids.include?(item.component_id) }.map(&:component)
    excluded_ids = params[:change_unlocked] == "1" ? old_items.reject { |item| locked_ids.include?(item.component_id) }.map(&:component_id) : []
    @build.assign_attributes(build_params.slice(:wishes, :purpose))
    if params.dig(:build, :budget_rubles).present?
      unless valid_budget?(params.dig(:build, :budget_rubles))
        return redirect_to @build, alert: "Бюджет должен быть от 10 000 до 5 000 000 ₽. Сборка не изменена."
      end
      @build.budget_cents = params[:build][:budget_rubles].to_i * 100
    end
    unless @build.valid?
      return redirect_to @build, alert: @build.errors.full_messages.to_sentence
    end
    parts = BuildOptimizer.new(@build, fixed: fixed, excluded_ids: excluded_ids).call
    @build.replace_configuration!(parts, locked_ids: fixed.map(&:id))
    redirect_to @build, notice: "Подбор обновлён. Зафиксированные детали сохранены."
  rescue BuildOptimizer::NoSolution => error
    redirect_to @build, alert: "#{error.message} Исходная сборка сохранена."
  end

  def replace_component
    replacement = Component.where(available: true).find(params[:component_id])
    items = @build.build_items.includes(:component).to_a
    old_item = items.find { |item| item.component.category == replacement.category }
    if old_item&.locked?
      return redirect_to @build, alert: "Деталь зафиксирована. Снимите фиксацию при пересборке."
    end
    fixed = items.reject { |item| item == old_item }.map(&:component) + [replacement]
    parts = BuildOptimizer.new(@build, fixed: fixed).call
    @build.replace_configuration!(parts, locked_ids: items.select(&:locked?).map(&:component_id))
    redirect_to @build, notice: "Комплектующее заменено. Бюджет и совместимость проверены."
  rescue BuildOptimizer::NoSolution => error
    redirect_to @build, alert: "#{error.message} Исходная сборка сохранена."
  end

  def destroy
    @build.destroy!
    redirect_to my_builds_path, notice: "Сборка удалена."
  end

  private

  def set_build
    @build = current_user.builds.find(params[:id])
  end

  def build_params
    params.fetch(:build, ActionController::Parameters.new).permit(:name, :purpose, :platform, :wishes)
  end

  def valid_budget?(value)
    value.to_s.match?(/\A\d+\z/) && (10_000..5_000_000).cover?(value.to_i)
  end
end
