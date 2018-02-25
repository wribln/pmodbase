class CreateDsrDocGroups < ActiveRecord::Migration[5.1]
  def change
    create_table :dsr_doc_groups do |t|
      t.string      :code,  limit: MAX_LENGTH_OF_CODE
      t.string      :title, limit: MAX_LENGTH_OF_TITLE
      t.belongs_to  :group, null: false, index: true

      t.timestamps null: false
    end
  end
end
