class CreateIdempotencyRequests < ActiveRecord::Migration[7.2]
  def change
    create_table :idempotency_requests do |t|
      t.references :user, null: false, foreign_key: true
      t.string :key, null: false
      t.string :endpoint, null: false
      t.string :request_fingerprint, null: false
      t.string :status, null: false, default: "processing"
      t.jsonb :response_body
      t.integer :response_status
      t.datetime :expires_at, null: false

      t.timestamps
    end

    add_index :idempotency_requests, :key,
              unique: true,
              name: "idx_idempotency_requests_unique_key"
    add_index :idempotency_requests, :expires_at
  end
end
