class AddTimesUsedToCoupons < ActiveRecord::Migration[7.2]
  def change
    add_column :coupons, :times_used, :integer
  end
end
