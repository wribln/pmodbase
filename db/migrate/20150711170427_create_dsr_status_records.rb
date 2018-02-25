class CreateDsrStatusRecords < ActiveRecord::Migration[5.1]
  def change
    create_table :dsr_status_records do |t|
      t.string      :title,           limit: MAX_LENGTH_OF_TITLE
      t.integer     :document_status,   default: 0
      t.integer     :document_status_b, default: 0
      t.string      :project_doc_id,  limit: MAX_LENGTH_OF_DOC_ID
      t.belongs_to  :sender_group,      null: false
      t.belongs_to  :sender_group_b,    null: false
      t.string      :sender_doc_id,   limit: MAX_LENGTH_OF_DOC_ID
      t.belongs_to  :receiver_group
      t.string      :receiver_doc_id, limit: MAX_LENGTH_OF_DOC_ID
      t.integer     :sub_purpose,     default: 0
      t.integer     :sub_frequency,   default: 0
      t.integer     :quantity,				default: 1
      t.integer     :quantity_b,      default: 0
      t.decimal     :weight,				  default: 1.0
      t.decimal     :weight_b,        default: 0.0
      t.belongs_to  :dsr_doc_group,          index: true, foreign_key: :true
      t.belongs_to  :submission_group,       index: true
      t.belongs_to  :submission_group_b,     index: true
      t.belongs_to  :prep_activity,          index: true
      t.belongs_to  :subm_activity,          index: true
      t.references  :dsr_current_submission, index: true
      #
      t.date        :plnd_prep_start
      t.date        :plnd_prep_start_b
      t.date        :estm_prep_start
      t.date        :actl_prep_start
      #
      t.date        :plnd_submission_1
      t.date        :plnd_submission_b
      t.date        :estm_submission
      t.date        :actl_submission_1
      t.date        :next_submission
      #
      t.date        :plnd_completion
      t.date        :plnd_completion_b
      t.date        :estm_completion
      t.date        :actl_completion
      #
      t.datetime    :baseline_date
      t.string      :notes,           limit: MAX_LENGTH_OF_NOTE
      t.integer     :current_status,    default: 0, null: false
      t.integer     :current_status_b,  default: 0, null: false
      t.integer     :current_task,      default: 0, null: false
      t.integer     :current_task_b,    default: 0, null: false

      t.timestamps null: false
    end
    add_foreign_key :dsr_status_records, :groups, column: :sender_group_id
    add_foreign_key :dsr_status_records, :groups, column: :sender_group_b_id
    add_foreign_key :dsr_status_records, :groups, column: :receiver_group_id
    add_foreign_key :dsr_status_records, :submission_groups, column: :submission_group_id
    add_foreign_key :dsr_status_records, :submission_groups, column: :submission_group_b_id
    add_foreign_key :dsr_status_records, :programme_activities, column: :prep_activity_id
    add_foreign_key :dsr_status_records, :programme_activities, column: :subm_activity_id
  end
end
