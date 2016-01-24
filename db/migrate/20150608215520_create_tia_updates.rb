class CreateTiaUpdates < ActiveRecord::Migration
  def change
    create_table :tia_updates do |t|
      t.belongs_to  :tia_item, null: false, index: true
      t.belongs_to  :account
      t.string      :description, length: MAX_LENGTH_OF_DESCRIPTION
      t.string      :comment,     length: MAX_LENGTH_OF_DESCRIPTION
      t.integer     :prio
      t.integer     :status
      t.date        :due_date
      t.boolean     :archived

      t.timestamps null: false
    end
    add_index :tia_updates, [ :tia_item_id, :created_at ], order: { created_at: :desc }
  end
end
