class CreateNotices < ActiveRecord::Migration[8.1]
  def change
    create_table :notices do |t|
      t.string :title, null: false
      t.text :content, null: false
      t.string :notice_type, null: false
      t.boolean :admin_only, default: false, null: false
      t.datetime :start_at, null: false
      t.datetime :end_at, null: false
      t.references :posted_by_user, null: false, foreign_key: { to_table: :users }, index: false
      t.references :parent_notice, foreign_key: { to_table: :notices }, index: true

      t.timestamps
    end

    add_index :notices, [:start_at, :end_at]
    add_index :notices, :notice_type
  end
end
