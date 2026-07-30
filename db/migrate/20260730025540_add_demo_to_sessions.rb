class AddDemoToSessions < ActiveRecord::Migration[8.1]
  def change
    add_column :sessions, :demo, :boolean, null: false, default: false
  end
end
