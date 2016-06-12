class CreateReferences < ActiveRecord::Migration
  def change
    create_table :references do |t|
      t.string :code,           limit: MAX_LENGTH_OF_CODE,        null: false, index: true, unique: true            
      t.string :description,    limit: MAX_LENGTH_OF_DESCRIPTION  
      t.string :project_doc_id, limit: MAX_LENGTH_OF_DOC_ID

      t.timestamps null: false
    end
  end
end
