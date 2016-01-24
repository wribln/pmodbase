class CreateGlossaryItems < ActiveRecord::Migration
  def change
    create_table :glossary_items do |t|
      t.string      :term,     limit: MAX_LENGTH_OF_TERM,         null: false, index: true
      t.string      :code,     limit: MAX_LENGTH_OF_CODE,                      index: true
      t.text        :description
      t.belongs_to  :reference

      t.timestamps null: false
    end
  end
end

