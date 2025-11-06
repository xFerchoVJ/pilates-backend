class CreateTransactions < ActiveRecord::Migration[7.2]
  def change
    create_table :transactions do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :amount, null: false
      t.string :currency, default: "mxn", null: false
      t.string :transaction_type, null: false
      t.integer :reference_id, null: false
      t.string :reference_type, null: false
      t.string :payment_intent_id, null: false
      t.jsonb :metadata
      t.string :status, default: "pending", null: false

      t.timestamps
    end
  end
end
