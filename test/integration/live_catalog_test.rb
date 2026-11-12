require "test_helper"

class LiveCatalogTest < ActionDispatch::IntegrationTest
  setup { load Rails.root.join("db/seeds.rb") }

  test "renders the live catalog shell and data endpoint" do
    get live_catalog_path

    assert_response :success
    assert_select "[data-live-catalog]"
    assert_select "[data-live-grid]"

    get live_catalog_data_path, as: :json

    assert_response :success
    assert_includes response.headers["Cache-Control"], "no-store"
    payload = JSON.parse(response.body)
    assert_operator payload.fetch("total"), :>, 0
    first = payload.fetch("components").first
    assert_match %r{\A(?:https://|/component-images/catalog/)}, first.fetch("image_url")
    assert first.fetch("updated_at").present?
  end

  test "filters live catalog data by category and query" do
    get live_catalog_data_path, params: { category: "gpu", q: "RTX" }, as: :json

    assert_response :success
    payload = JSON.parse(response.body)
    assert payload.fetch("components").all? { |part| part.fetch("category") == "gpu" }
    assert payload.fetch("components").all? { |part| part.fetch("name").include?("RTX") }
  end
end
