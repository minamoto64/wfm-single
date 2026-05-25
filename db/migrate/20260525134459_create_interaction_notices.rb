class CreateInteractionNotices < ActiveRecord::Migration[8.1]
  def change
    create_table :interaction_notices do |t|
      t.references :interaction, null: false, foreign_key: true
      t.references :notice, null: false, foreign_key: true

      t.timestamps
    end

    add_index :interaction_notices, [:interaction_id, :notice_id], unique: true
  end
end
