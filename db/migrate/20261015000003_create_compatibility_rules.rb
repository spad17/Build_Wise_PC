class CreateCompatibilityRules < ActiveRecord::Migration[8.1]
  def change
    create_table :compatibility_rules do |t|
      t.references :component, null: false, foreign_key: true
      t.references :compatible_component, null: false, foreign_key: { to_table: :components }
      t.string :note

      t.timestamps
    end

    add_index :compatibility_rules, [:component_id, :compatible_component_id], unique: true,
              name: "index_compatibility_rules_on_component_pair"
  end
end
