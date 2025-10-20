class CreateLoungeDesigns < ActiveRecord::Migration[7.2]
  def change
    create_table :lounge_designs do |t|
      t.string :name, null: false
      t.text :description
      t.jsonb :layout_json, null: false

      t.timestamps
    end
  end
end
