class CreateGroupCategories < ActiveRecord::Migration
  def change
    create_table :group_categories do |t|
      t.string :label, length: MAX_LENGTH_OF_LABEL, null: false, default: ''
      t.integer :seqno, null: false, default: 0

      t.timestamps null: false
    end
    add_index :group_categories,
    	[ :seqno, :label ],
    	name: :group_categories_key2,
    	order: { seqno: :asc, label: :asc }
  end
end
