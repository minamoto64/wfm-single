class AddRootToNotices < ActiveRecord::Migration[8.1]
  def change
    add_reference :notices,
                  :root,
                  foreign_key: {
                    to_table: :notices
                  }
  end
end
