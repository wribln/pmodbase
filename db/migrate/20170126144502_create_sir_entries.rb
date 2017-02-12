class CreateSirEntries < ActiveRecord::Migration
  def change
    create_table :sir_entries do |t|
      t.belongs_to  :sir_item,   index: true, foreign_key: true
      t.belongs_to  :group,      index: true, foreign_key: true
      t.integer     :rec_type,   null: false
      t.date        :due_date
      t.boolean     :is_public,  default: false, null: false
      t.text        :description

      t.timestamps  null: false
    end
    add_index :sir_entries, [ :sir_item_id, :created_at ],
              order: { sir_item_id: :asc, created_at: :asc },
              name: 'sir_entries_default_order'
    add_index :sir_entries, [ :sir_item_id, :created_at ],
              order: { sir_item_id: :asc, create_at: :desc },
              name: 'sir_entries_reverse_order'
  end
end
