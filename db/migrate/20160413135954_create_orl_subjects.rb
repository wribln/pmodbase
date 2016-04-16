class CreateOrlSubjects < ActiveRecord::Migration
  def change
    create_table :orl_subjects do |t|
      t.belongs_to  :orl_category,  null: false,  index: true, foreign_key: true
      t.belongs_to  :o_group,       null: false,  index: true, foreign_key: true
      t.belongs_to  :r_group,       null: false,  index: true, foreign_key: true
      t.belongs_to  :o_owner,       null: false,  index: true, foreign_key: true
      t.belongs_to  :o_deputy,                    index: true, foreign_key: true
      t.belongs_to  :r_owner,       null: false,  index: true, foreign_key: true
      t.belongs_to  :r_deputy,                    index: true, foreign_key: true
      t.string      :desc,            limit: MAX_LENGTH_OF_DESCRIPTION
      t.string      :note,            limit: MAX_LENGTH_OF_NOTE
      t.string      :project_doc_id,  limit: MAX_LENGTH_OF_DOC_ID
      t.string      :report_doc_id,   limit: MAX_LENGTH_OF_DOC_ID
      t.boolean     :archived, default: false

      t.timestamps null: false
    end
    add_index :orl_subjects, [ :archived, :orl_category_id, :id ], order: { orl_cateogry_id: :asc, id: :desc }, name: 'active_orl_subjects'
  end
end
