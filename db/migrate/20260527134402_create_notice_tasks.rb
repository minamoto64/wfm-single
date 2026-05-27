class CreateNoticeTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :notice_tasks do |t|
      t.references :notice, null: false, foreign_key: true
      t.references :task, null: false, foreign_key: true

      t.timestamps
    end
    add_index :notice_tasks, [:notice_id, :task_id], unique: true
  end
end
