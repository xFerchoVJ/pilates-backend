class AddExpiresAtToClassCredits < ActiveRecord::Migration[7.2]
  def change
    add_column :class_credits, :expires_at, :datetime
    add_index :class_credits, :expires_at
  end
end
