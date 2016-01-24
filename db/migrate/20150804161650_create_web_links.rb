class CreateWebLinks < ActiveRecord::Migration
  def change
    create_table :web_links do |t|
      t.string 	:label, length: MAX_LENGTH_OF_LABEL, null: false, default: ''
      t.text 	:hyperlink
      t.integer :seqno, null: false, default: 0

      t.timestamps null: false
    end
    add_index :web_links,
    	[ :seqno, :label ],
    	name: :web_links_key2,
    	order: { seqno: :asc, label: :asc }
  end
end
