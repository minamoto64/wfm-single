class CreateInteractions < ActiveRecord::Migration[8.1]
  def change
    create_table :interactions do |t|
      t.references :customer, null: false, foreign_key: true, index: false
      t.references :user, null: false, foreign_key: true, index: false
      t.datetime :occurred_at, null: false
      t.string :interaction_type, null: false
      t.text :request_content, null: false
      t.text :response_result, null: false
      t.boolean :completed, default: false, null: false
      t.references :parent_interaction, foreign_key: { to_table: :interactions }, index: true

      t.timestamps
    end

    add_index :interactions, [:customer_id, :occurred_at]
    add_index :interactions, [:user_id, :occurred_at]
    add_index :interactions, :interaction_type
  end
end
