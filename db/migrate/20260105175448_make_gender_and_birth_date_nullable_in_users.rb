class MakeGenderAndBirthDateNullableInUsers < ActiveRecord::Migration[7.2]
  def change
    change_column_null :users, :gender, true
    change_column_null :users, :birthdate, true
  end
end
