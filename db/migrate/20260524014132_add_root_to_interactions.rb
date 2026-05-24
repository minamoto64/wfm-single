class AddRootToInteractions < ActiveRecord::Migration[8.1]
  def change
    add_reference :interactions,
              :root,
              foreign_key: { to_table: :interactions }
  end
end
