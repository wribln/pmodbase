class CreateRfcDocuments < ActiveRecord::Migration[5.1]
  def change
    create_table :rfc_documents do |t|
      t.belongs_to  :rfc_status_record, null: false, foreign_key: :true, index: :true
      t.integer     :version, default: 0,  null: false
      t.text        :question
      t.text        :answer
      t.text        :note
      t.belongs_to  :account, null: false

      t.timestamps null: false
    end
    add_index :rfc_documents,
      [ :rfc_status_record_id, :version ], 
      name: :main_key, 
      order: { rfc_status_record_id: :asc, version: :desc },
      unique: true
  end
end
