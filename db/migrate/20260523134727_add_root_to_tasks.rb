class AddRootToTasks < ActiveRecord::Migration[8.1]
  def change
    add_reference :tasks,
                  :root,
                  foreign_key: {
                    to_table: :tasks
                  }
  end
end
