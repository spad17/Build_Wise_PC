class CreateBuildItems < ActiveRecord::Migration[8.1]
  def change
    create_table :build_items do |t|
      t.references :build, null: false, foreign_key: true
      t.references :component, null: false, foreign_key: true
      t.integer :quantity, null: false, default: 1

      t.timestamps
    end

    add_index :build_items, [:build_id, :component_id], unique: true
  end
end
