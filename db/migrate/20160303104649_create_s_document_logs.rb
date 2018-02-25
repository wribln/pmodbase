class CreateSDocumentLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :s_document_logs do |t|
      t.belongs_to :group,        null: false, foreign_key: :true
      t.belongs_to :account,      null: false, foreign_key: :true
      t.string :receiver_group,   limit: MAX_LENGTH_OF_CODE
      t.string :function_code,    limit: MAX_LENGTH_OF_CODE
      t.string :service_code,     limit: MAX_LENGTH_OF_CODE
      t.string :product_code,     limit: MAX_LENGTH_OF_CODE
      t.string :location_code,    limit: MAX_LENGTH_OF_CODE
      t.string :phase_code,       limit: MAX_LENGTH_OF_CODE
      t.string :dcc_code,         limit: MAX_LENGTH_OF_CODE
      t.string :revision_code,    limit: MAX_LENGTH_OF_CODE
      t.date :author_date
      t.string :title,            limit: MAX_LENGTH_OF_TITLE
      t.string :doc_id,           limit: MAX_LENGTH_OF_DOC_ID_S

      t.timestamps null: false
    end
    add_index :s_document_logs, :id, order: :desc
  end
end
