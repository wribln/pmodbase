class CreateSirItems < ActiveRecord::Migration
  def change
    create_table :sir_items do |t|
      t.belongs_to  :sir_log,     index: true, foreign_key: true
      t.belongs_to  :group,       index: true, foreign_key: true
      t.belongs_to  :cfr_record,               foreign_key: true
      t.belongs_to  :phase_code,  index: true, foreign_key: true
      t.string      :ref_id,                   limit: MAX_LENGTH_OF_NOTE
      t.string      :label,       null: false, limit: MAX_LENGTH_OF_LABEL
      t.integer     :status,      null: false
      t.integer     :category,    null: false
      t.boolean     :archived,    null: false, default: false
      t.text        :desc

      t.timestamps null: false
    end
  end
end
