class CreateInteractionTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :interaction_tasks do |t|
      t.references :interaction, null: false, foreign_key: true
      t.references :task, null: false, foreign_key: true

      t.timestamps
    end

    add_index :interaction_tasks, [:interaction_id, :task_id], unique: true
  end
end
