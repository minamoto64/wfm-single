class AddUuidToCustomers < ActiveRecord::Migration[8.1]
  def change
    add_column :customers, :uuid, :uuid, null: false, default: "gen_random_uuid()"
    add_index :customers, :uuid, unique: true
  end
end
