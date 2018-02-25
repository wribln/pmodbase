class CreateCsrStatusRecords < ActiveRecord::Migration[5.1]
  def change
    create_table :csr_status_records do |t|
      t.integer   :correspondence_type, null: false, index: true
      t.integer   :transmission_type
      t.string    :subject,             limit: MAX_LENGTH_OF_TITLE
      t.integer   :sender_group_id
      t.integer   :receiver_group_id
      t.integer   :classification
      t.date      :correspondence_date
      t.date      :plan_reply_date
      t.date      :actual_reply_date
      t.integer   :reply_status_record_id
      t.integer   :status, default: 0
      t.string    :project_doc_id,      limit: MAX_LENGTH_OF_DOC_ID
      t.string    :sender_doc_id,       limit: MAX_LENGTH_OF_DOC_ID
      t.string    :sender_reference,    limit: MAX_LENGTH_OF_DOC_ID
      t.string    :notes,               limit: MAX_LENGTH_OF_NOTE

      t.timestamps null: false
    end
    add_index :csr_status_records, :correspondence_date, order: :desc
  end
end
