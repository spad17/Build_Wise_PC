class AddConfigurator < ActiveRecord::Migration[8.1]
  def change
    add_column :components, :description, :text
    add_column :components, :performance, :integer, null: false, default: 1
    add_column :components, :memory_type, :string
    add_column :components, :capacity_gb, :integer
    add_column :components, :quiet, :boolean, null: false, default: false
    add_column :components, :specs, :json, null: false, default: {}
    add_column :builds, :wishes, :text
    add_column :build_items, :locked, :boolean, null: false, default: false
    create_table :reviews do |t|
      t.references :user, null: false, foreign_key: true
      t.references :component, null: false, foreign_key: true
      t.integer :rating, null: false
      t.text :body, null: false
      t.timestamps
    end
    add_index :reviews, [:user_id, :component_id], unique: true
  end
end
