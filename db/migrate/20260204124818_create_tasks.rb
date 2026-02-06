class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.boolean :admin_only, default: false, null: false
      t.datetime :due_at
      t.references :created_by_user, null: false, foreign_key: { to_table: :users }, index: false
      t.references :parent_task, foreign_key: { to_table: :tasks }, index: true

      t.timestamps
    end

    add_index :tasks, :due_at
  end
end
