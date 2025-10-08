class CreateInjuries < ActiveRecord::Migration[7.2]
  def change
    create_table :injuries do |t|
      t.references :user, null: false, foreign_key: true
      t.string :injury_type
      t.text :description
      t.string :severity
      t.date :date_ocurred
      t.boolean :recovered

      t.timestamps
    end
  end
end
