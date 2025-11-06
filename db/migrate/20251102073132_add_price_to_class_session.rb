class AddPriceToClassSession < ActiveRecord::Migration[7.2]
  def change
    add_column :class_sessions, :price, :integer
  end
end
