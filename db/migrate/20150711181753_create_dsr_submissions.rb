class CreateDsrSubmissions < ActiveRecord::Migration[5.1]
  def change
    create_table :dsr_submissions do |t|
      t.belongs_to  :dsr_status_record,         null: false
      t.integer     :submission_no, default: 1, null: false
      t.string      :sender_doc_id_version,       limit: MAX_LENGTH_OF_DOC_VERSION
      t.string      :receiver_doc_id_version,     limit: MAX_LENGTH_OF_DOC_VERSION
      t.string      :project_doc_id_version,      limit: MAX_LENGTH_OF_DOC_VERSION
      t.string      :submission_receiver_doc_id,  limit: MAX_LENGTH_OF_DOC_ID
      t.string      :submission_project_doc_id,   limit: MAX_LENGTH_OF_DOC_ID
      t.string      :response_sender_doc_id,      limit: MAX_LENGTH_OF_DOC_ID
      t.string      :response_project_doc_id,     limit: MAX_LENGTH_OF_DOC_ID
      t.date        :plnd_submission
      t.date        :actl_submission
      t.date        :xpcd_response
      t.date        :actl_response
      t.integer     :response_status

      t.timestamps null: false
    end
    add_index :dsr_submissions,
      [ :dsr_status_record_id, :submission_no ],
      name: :dsr_submissions_key2,
      order: { dsr_status_record_id: :asc, submission_no: :asc },
      unique: true
  end
end
