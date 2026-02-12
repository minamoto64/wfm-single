class RenameColumnsForConsistency < ActiveRecord::Migration[8.1]
  def change
    # remove foreign_key
    remove_foreign_key :interactions, column: :parent_interaction_id
    remove_foreign_key :notices, column: :parent_notice_id
    remove_foreign_key :notices, column: :posted_by_user_id
    remove_foreign_key :tasks, column: :parent_task_id
    remove_foreign_key :tasks, column: :created_by_user_id

    # interactions
    rename_column :interactions, :interaction_type, :channel
    rename_column :interactions, :parent_interaction_id, :parent_id

    # notices
    rename_column :notices, :admin_only, :restricted
    rename_column :notices, :notice_type, :level
    rename_column :notices, :parent_notice_id, :parent_id
    rename_column :notices, :posted_by_user_id, :user_id

    # tasks
    rename_column :tasks, :admin_only, :restricted
    rename_column :tasks, :parent_task_id, :parent_id
    rename_column :tasks, :created_by_user_id, :user_id

    # add foreign_key
    add_foreign_key :interactions, :interactions, column: :parent_id
    add_foreign_key :notices, :notices, column: :parent_id
    add_foreign_key :notices, :users, column: :user_id
    add_foreign_key :tasks, :tasks, column: :parent_id
    add_foreign_key :tasks, :users, column: :user_id
  end
end
