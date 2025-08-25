class CreateRefreshTokenUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :refresh_token_users do |t|
      t.references :user, null: false, foreign_key: true
      t.string :jti
      t.string :user_agent
      t.string :ip
      t.datetime :expires_at
      t.datetime :revoked_at

      t.timestamps
    end
    add_index :refresh_token_users, :jti
  end
end
