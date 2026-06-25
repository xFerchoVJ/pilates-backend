class CreateClassCreditAdjustments < ActiveRecord::Migration[7.2]
  def change
    create_table :class_credit_adjustments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :admin_user, foreign_key: { to_table: :users }
      t.integer :amount, null: false
      t.text :reason, null: false
      t.jsonb :credit_ids, null: false, default: []
      t.jsonb :metadata, null: false, default: {}

      t.timestamps
    end

    add_index :class_credit_adjustments, :created_at
  end
end
