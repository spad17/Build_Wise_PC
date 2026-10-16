class CreateBuilds < ActiveRecord::Migration[8.1]
  def change
    create_table :builds do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.string :purpose, null: false
      t.string :platform, null: false, default: "x86-64"
      t.string :status, null: false, default: "draft"
      t.integer :budget_cents, null: false, default: 0

      t.timestamps
    end

    add_index :builds, [:user_id, :created_at]
    add_index :builds, :status
  end
end
