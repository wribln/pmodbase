class CreateSirEntries < ActiveRecord::Migration[5.1]
  def change
    create_table :sir_entries do |t|
      t.belongs_to  :sir_item,  index: true, foreign_key: true
      t.belongs_to  :orig_group, null: false
      t.belongs_to  :resp_group, null: false
      t.integer     :rec_type,   null: false
      t.date        :due_date
      t.text        :description

      t.timestamps  null: false
    end
    add_foreign_key :sir_entries, :groups, column: :orig_group_id
    add_foreign_key :sir_entries, :groups, column: :resp_group_id
    add_index :sir_entries, [ :sir_item_id, :created_at ],
              order: { sir_item_id: :asc, created_at: :asc },
              name: 'sir_entries_default_order'
    add_index :sir_entries, [ :sir_item_id, :created_at ],
              order: { sir_item_id: :asc, create_at: :desc },
              name: 'sir_entries_reverse_order'
  end
end
