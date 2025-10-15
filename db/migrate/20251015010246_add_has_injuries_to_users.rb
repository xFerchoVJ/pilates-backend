class AddHasInjuriesToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :has_injuries, :string, null: false, default: "pending"
  end
end
