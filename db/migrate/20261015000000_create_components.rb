class CreateComponents < ActiveRecord::Migration[8.1]
  def change
    create_table :components do |t|
      t.string :name, null: false
      t.string :manufacturer, null: false
      t.string :category, null: false
      t.string :platform, null: false, default: "x86-64"
      t.string :socket
      t.integer :price_cents, null: false, default: 0
      t.integer :power_watts
      t.integer :memory_gb
      t.boolean :available, null: false, default: true

      t.timestamps
    end

    add_index :components, :category
    add_index :components, :platform
    add_index :components, [:manufacturer, :name], unique: true
  end
end
