class CreatePcpSubjects < ActiveRecord::Migration
  def change
    create_table :pcp_subjects do |t|
      t.belongs_to  :pcp_category,  null: false,  index: true, foreign_key: true
      t.belongs_to  :c_group,       null: false,  index: true, foreign_key: true
      t.belongs_to  :p_group,       null: false,  index: true, foreign_key: true
      t.belongs_to  :c_owner,       null: false,  index: true, foreign_key: true
      t.belongs_to  :c_deputy,                    index: true, foreign_key: true
      t.belongs_to  :p_owner,       null: false,  index: true, foreign_key: true
      t.belongs_to  :p_deputy,                    index: true, foreign_key: true
      t.string      :title,           limit: MAX_LENGTH_OF_TITLE
      t.string      :note,            limit: MAX_LENGTH_OF_NOTE
      t.string      :project_doc_id,  limit: MAX_LENGTH_OF_DOC_ID
      t.string      :report_doc_id,   limit: MAX_LENGTH_OF_DOC_ID
      t.boolean     :archived, default: false

      t.timestamps null: false
    end
    add_index :pcp_subjects, [ :archived, :pcp_category_id, :id ], order: { pcp_cateogry_id: :asc, id: :desc }, name: 'active_pcp_subjects'
  end
end
