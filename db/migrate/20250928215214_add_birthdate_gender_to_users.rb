class AddBirthdateGenderToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :gender, :string, null: false
    add_column :users, :birthdate, :date, null: false
  end
end
