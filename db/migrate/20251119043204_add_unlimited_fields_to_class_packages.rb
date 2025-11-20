class AddUnlimitedFieldsToClassPackages < ActiveRecord::Migration[7.2]
  def change
    add_column :class_packages, :unlimited, :boolean, default: false, null: false
    add_column :class_packages, :expires_in_days, :integer
    add_column :class_packages, :daily_limit, :integer
  end
end
