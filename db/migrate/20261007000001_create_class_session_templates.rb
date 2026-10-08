class CreateClassSessionTemplates < ActiveRecord::Migration[7.2]
  def change
    create_table :class_session_templates do |t|
      t.string :name, null: false
      t.text :description
      t.string :status, null: false, default: "active"
      t.timestamps
    end

    add_check_constraint :class_session_templates,
                         "status IN ('active', 'archived')",
                         name: "chk_class_session_templates_status"

    create_table :class_session_template_items do |t|
      t.references :class_session_template, null: false, foreign_key: true
      t.integer :day_of_week, null: false
      t.time :start_time, null: false
      t.time :end_time, null: false
      t.string :name, null: false
      t.text :description
      t.references :instructor, null: false, foreign_key: { to_table: :users }
      t.references :lounge, null: false, foreign_key: true
      t.integer :price, null: false
      t.timestamps
    end

    add_check_constraint :class_session_template_items,
                         "day_of_week BETWEEN 0 AND 6",
                         name: "chk_class_session_template_items_day"
    add_index :class_session_template_items,
              [ :class_session_template_id, :day_of_week, :start_time ],
              name: "idx_template_items_day_start"

    create_table :class_session_template_publications do |t|
      t.references :class_session_template, null: false, foreign_key: true
      t.date :week_start, null: false
      t.timestamps
    end

    add_index :class_session_template_publications,
              [ :class_session_template_id, :week_start ],
              unique: true,
              name: "idx_template_publications_template_week"

    add_reference :class_sessions,
                  :class_session_template_publication,
                  foreign_key: true,
                  null: true,
                  index: true
  end
end
