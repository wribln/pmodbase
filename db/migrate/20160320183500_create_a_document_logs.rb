class CreateADocumentLogs < ActiveRecord::Migration
  def change
    create_table :a_document_logs do |t|
      t.string :a1_code, limit: MAX_LENGTH_OF_CODE, null: false
      t.string :a2_code, limit: MAX_LENGTH_OF_CODE, null: false
      t.string :a3_code, limit: MAX_LENGTH_OF_CODE, null: false
      t.string :a4_code, limit: MAX_LENGTH_OF_CODE, null: false
      t.string :a5_code, limit: MAX_LENGTH_OF_CODE, null: false
      t.string :a6_code, limit: MAX_LENGTH_OF_CODE, null: false
      t.string :a7_code, limit: MAX_LENGTH_OF_CODE, null: false
      t.string :a8_code, limit: MAX_LENGTH_OF_CODE, null: false
      t.belongs_to :account,      null: false 
      t.string :title,        limit: MAX_LENGTH_OF_TITLE
      t.string :doc_id,       limit: MAX_LENGTH_OF_DOC_ID_A

      t.timestamps null: false
    end
    add_index :a_document_logs, :id, order: :desc
  end
end
