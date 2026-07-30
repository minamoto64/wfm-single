class AddDemoToCoreTables < ActiveRecord::Migration[8.1]
  def change
    %i[users customers interactions notices tasks comments task_assignments].each do |table|
      add_column table, :demo, :boolean, null: false, default: false
      add_index table, :demo
    end
  end
end
