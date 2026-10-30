# Multiple-choice knapsack: one item per category. Branch-and-bound searches
# complete compatible configurations, using optimistic score and minimum cost bounds.
class BuildOptimizer
  CATEGORIES = %w[cpu motherboard memory gpu storage case cooler psu].freeze
  PURPOSE_WEIGHTS = {
    "Игры" => { "gpu" => 5, "cpu" => 3 },
    "Монтаж и 3D" => { "cpu" => 5, "gpu" => 4, "memory" => 3 },
    "Программирование" => { "cpu" => 4, "memory" => 4, "storage" => 2 },
    "Работа и учёба" => { "cpu" => 3, "storage" => 3 }
  }.freeze
  class NoSolution < StandardError; end

  attr_reader :preferences

  def initialize(build, fixed: [], excluded_ids: [])
    @build, @fixed, @excluded_ids = build, fixed, excluded_ids
    @budget = build.budget_cents
    @preferences = self.class.parse_wishes(build.wishes)
    @best, @best_score, @best_cost = nil, -1, Float::INFINITY
    @compatibility_cache = {}
  end

  def self.parse_wishes(text)
    text = text.to_s.downcase
    memory = text.match(/(\d+)\s*(?:гб|gb)\s*(?:озу|ram|памят)/) || text.match(/(?:озу|ram|памят[ьи])\s*(?:от|минимум)?\s*(\d+)\s*(?:гб|gb)/)
    storage = text.match(/(\d+)\s*(тб|tb|гб|gb)\s*(?:ssd|ссд|накопител)/) || text.match(/(?:ssd|ссд|накопител[ья]?)\s*(?:от|минимум)?\s*(\d+)\s*(тб|tb|гб|gb)/)
    { memory_gb: memory ? memory[1].to_i : 0,
      storage_gb: storage ? storage[1].to_i * (%w[тб tb].include?(storage[2]) ? 1024 : 1) : 0,
      quiet: text.include?("тих") || text.include?("тишин") }
  end

  def call
    if @build.platform == "E2K" && !Component.where(category: "cooler", platform: "E2K", available: true).exists?
      raise NoSolution, "Для Эльбруса E2K нужна подтверждённая комплектация поставщика МЦСТ: модуль уже содержит CPU, охлаждение и драйверы периферии проверяются отдельно. Выберите x64 или Threadripper для автоматического подбора."
    end
    catalog = Component.includes(:compatible_components).where(available: true).for_platform(@build.platform).where.not(id: @excluded_ids).to_a
    @fixed.each { |part| part.association(:compatible_components).load_target }
    @groups = CATEGORIES.map do |category|
      pinned = @fixed.find { |item| item.category == category }
      choices = pinned ? [pinned] : catalog.select { |item| item.category == category }
      choices.select { |item| eligible?(item) }.sort_by { |item| [-score(item), item.price_cents, item.id] }
    end
    if @groups.any?(&:empty?)
      raise NoSolution, "В каталоге нет деталей под эти ограничения. Измените пожелания, выбранные детали или архитектуру."
    end
    @min_cost = Array.new(CATEGORIES.size + 1, 0)
    @max_score = Array.new(CATEGORIES.size + 1, 0)
    (CATEGORIES.size - 1).downto(0) do |i|
      @min_cost[i] = @min_cost[i + 1] + @groups[i].map(&:price_cents).min
      @max_score[i] = @max_score[i + 1] + @groups[i].map { |item| score(item) }.max
    end
    search(0, [], 0, 0)
    @best || raise(NoSolution, "Совместимая сборка не найдена. Увеличьте бюджет, снимите фиксацию деталей или смягчите пожелания. Минимум без учёта совместимости: #{@min_cost[0] / 100} ₽.")
  end

  private

  def eligible?(item)
    return false unless item.available? && item.supports_platform?(@build.platform)
    return false if item.category == "memory" && item.memory_gb.to_i < preferences[:memory_gb]
    return false if item.category == "storage" && item.capacity_gb.to_i < preferences[:storage_gb]
    true
  end

  def score(item)
    weight = PURPOSE_WEIGHTS.fetch(@build.purpose, {}).fetch(item.category, 1)
    item.performance * weight + (preferences[:quiet] && item.quiet? ? 100 : 0)
  end

  def search(index, selected, cost, value)
    return if cost + @min_cost[index] > @budget
    return if value + @max_score[index] < @best_score
    return if value + @max_score[index] == @best_score && cost + @min_cost[index] >= @best_cost
    if index == CATEGORIES.size
      return unless self.class.power_sufficient?(selected)
      if value > @best_score || (value == @best_score && cost < @best_cost)
        @best, @best_score, @best_cost = selected.dup, value, cost
      end
      return
    end
    @groups[index].each do |item|
      next if cost + item.price_cents > @budget
      next unless selected.all? { |other| compatible_pair?(item, other) }
      if item.category == "cooler"
        cpu = selected.find { |part| part.category == "cpu" }
        next if cpu && !item.cools?(cpu)
      end
      search(index + 1, selected + [item], cost + item.price_cents, value + score(item))
    end
  end

  def compatible_pair?(left, right)
    key = [left.id, right.id].sort
    return @compatibility_cache[key] if @compatibility_cache.key?(key)
    @compatibility_cache[key] = left.compatible_with?(right)
  end

  public

  def self.power_sufficient?(parts)
    psu = parts.find { |part| part.category == "psu" }
    return false unless psu
    demand = parts.reject { |part| part.category == "psu" }.sum { |part| part.power_watts.to_i }
    recommendation = parts.find { |part| part.category == "gpu" }&.specs&.fetch("recommended_psu_watts", 0).to_i
    psu.power_watts.to_i >= [(demand * 1.25).ceil, recommendation].max
  end
end
