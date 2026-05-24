class DropUnintendedTables < ActiveRecord::Migration[8.1]
  def change
    remove_column :interactions, :children_count

    drop_table :interaction_notices
    drop_table :task_relations
    drop_table :comments
    drop_table :active_storage_attachments
    drop_table :active_storage_variant_records
    drop_table :active_storage_blobs
  end
end
