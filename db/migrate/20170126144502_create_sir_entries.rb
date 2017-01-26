class CreateSirEntries < ActiveRecord::Migration
  def change
    create_table :sir_entries do |t|
      t.belongs_to  :sir_item,  index: true, foreign_key: true
      t.belongs_to  :group,     index: true, foreign_key: true
      t.belongs_to  :parent
      t.integer     :rec_type,  null: false
      t.date        :due_date
      t.integer     :no_sub_req
      t.text        :desc

      t.timestamps null: false
    end
    add_index :sir_entries, [ :sir_item_id, :created_at ],
              order: { sir_item_id: :asc, created_at: :asc },
              name: 'sir_entries_default_order'
  end
end
