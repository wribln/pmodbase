class CreateAbbreviations < ActiveRecord::Migration[5.1]
  def change
    create_table :abbreviations do |t|
      t.string :code,        limit: MAX_LENGTH_OF_CODE,         null: false
      t.string :sort_code,   limit: MAX_LENGTH_OF_CODE,         null: false, index: true
      t.string :description, limit: MAX_LENGTH_OF_DESCRIPTION,  null: false

      t.timestamps null: false
    end
  end
end
