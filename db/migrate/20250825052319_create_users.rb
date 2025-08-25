class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :email
      t.string :password_digest
      t.string :name
      t.string :last_name
      t.string :phone
      t.integer :role
      t.string :provider
      t.string :uid
      t.boolean :google_email_verified

      t.timestamps
    end
    add_index :users, :email, unique: true
  end
end
