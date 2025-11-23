class AddIsNewToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :is_new, :boolean, default: true
  end
end
