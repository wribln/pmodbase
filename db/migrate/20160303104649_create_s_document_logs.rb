class CreateSDocumentLogs < ActiveRecord::Migration
  def change
    create_table :s_document_logs do |t|
      t.belongs_to :group,        null: false
      t.string :receiver_group,   limit: MAX_LENGTH_OF_CODE
      t.string :function_code,    limit: MAX_LENGTH_OF_CODE
      t.string :service_code,     limit: MAX_LENGTH_OF_CODE
      t.string :product_code,     limit: MAX_LENGTH_OF_CODE
      t.string :location_code,    limit: MAX_LENGTH_OF_CODE
      t.string :phase_code,       limit: MAX_LENGTH_OF_CODE
      t.string :dcc_code,         limit: MAX_LENGTH_OF_CODE
      t.string :revision_code,    limit: MAX_LENGTH_OF_CODE
      t.date :author_date,        limit: MAX_LENGTH_OF_CODE
      t.belongs_to :account,      null: false 
      t.string :title,            limit: MAX_LENGTH_OF_CODE
      t.string :siemens_doc_id,   limit: MAX_LENGTH_OF_DOC_ID_S

      t.timestamps null: false
    end
    add_index :s_document_logs, :id, order: :desc
  end
end
