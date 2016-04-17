class CreatePcpSteps < ActiveRecord::Migration
  def change
    create_table :pcp_steps do |t|
      t.belongs_to  :pcp_subject, null: false, index: true, foreign_key: true
      t.integer     :step_no,     null: false, default: 0
      t.string      :subject_version, limit: MAX_LENGTH_OF_DOC_VERSION
      t.string      :note,            limit: MAX_LENGTH_OF_NOTE
      t.date        :subject_date
      t.date        :due_date
      t.integer     :subject_status, default: 0
      t.integer     :assessment, default: 0

      t.timestamps null: false
    end
    add_index :pcp_steps, [ :pcp_subject_id, :step_no ], order: { pcp_subject_id: :asc, step_no: :desc }, unique: :true, name: 'pcp_steps_index'
  end
end
