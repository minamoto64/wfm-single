class RemoveUuidFromCustomers < ActiveRecord::Migration[8.1]
  def change
    remove_column :customers, :uuid, :uuid, default: -> { "gen_random_uuid()" }, null: false
  end
end
