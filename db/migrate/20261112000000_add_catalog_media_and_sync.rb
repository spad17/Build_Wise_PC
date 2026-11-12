class AddCatalogMediaAndSync < ActiveRecord::Migration[8.1]
  def change
    add_column :components, :image_url, :string
    add_column :components, :image_credit, :string
    add_column :components, :data_synced_at, :datetime
    add_index :components, :data_synced_at
  end
end
