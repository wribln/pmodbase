class CreateRfcStatusRecords < ActiveRecord::Migration[5.1]
  def change
    create_table :rfc_status_records do |t|
      t.integer :rfc_type,                default: 0,                  null: false
      t.string  :title,                   limit: MAX_LENGTH_OF_TITLE
      t.integer :asking_group_id
      t.integer :answering_group_id
      t.string  :project_doc_id,          limit: MAX_LENGTH_OF_DOC_ID
      t.string  :project_rms_id,          limit: MAX_LENGTH_OF_RMS_ID
      t.string  :asking_group_doc_id,     limit: MAX_LENGTH_OF_DOC_ID
      t.string  :answering_group_doc_id,  limit: MAX_LENGTH_OF_DOC_ID
      t.integer :current_status,          default: 0,                  null: false
      t.integer :current_task,            default: 0,                  null: false

      t.timestamps null: false
    end
  end
end
