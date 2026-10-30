module ConfiguratorCatalog
  def load_configurator_catalog
    load Rails.root.join("db/seeds.rb")
  end

  def candidate_build(platform: "x86-64", budget: 100_000, wishes: nil)
    user = User.create!(username: "Builder", email: "builder@example.com", password: "password123")
    user.builds.new(name: "Тестовый ПК", purpose: "Игры", platform: platform, budget_cents: budget * 100, wishes: wishes)
  end
end
