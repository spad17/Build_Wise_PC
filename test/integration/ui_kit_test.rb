require "test_helper"

class UiKitTest < ActionDispatch::IntegrationTest
  test "renders the public UI kit page with the main component groups" do
    get ui_kit_path

    assert_response :success
    assert_select "h1", /Интерфейс/
    assert_select "h2", "Типографика"
    assert_select "h2", "Кнопки и статусы"
    assert_select "h2", "Формы и выбор"
    assert_select "h2", "Карточки и уведомления"
    assert_select "table.kit-table"
  end
end
