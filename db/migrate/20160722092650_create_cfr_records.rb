class CreateCfrRecords < ActiveRecord::Migration[5.1]
  def change
    create_table :cfr_records do |t|
      t.string      :title,       limit: MAX_LENGTH_OF_TITLE
      t.string      :note,        limit: MAX_LENGTH_OF_DESCRIPTION
      t.belongs_to  :group,       index: true, foreign_key: true
      t.integer     :conf_level,  default: 1

      t.string      :doc_version, limit: MAX_LENGTH_OF_DOC_VERSION
      t.string      :doc_date,    limit: MAX_LENGTH_OF_DOC_DATE
      t.string      :doc_owner,   limit: MAX_LENGTH_OF_ACCOUNT_INFO
      t.string      :extension,   limit:  MAX_LENGTH_OF_EXTENSION
      t.belongs_to  :cfr_file_type, index: true, foreign_key: true
      t.string      :hash_value,  limit: MAX_LENGTH_OF_HASH
      t.integer     :hash_function
      t.belongs_to  :main_location
      t.datetime    :freeze_date

      t.timestamps null: false
    end
    add_index :cfr_records, [ :id ], order: { id: :desc }, name: 'cfr_default_order'
  end
end
