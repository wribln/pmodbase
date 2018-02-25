class CreateCfrFileTypes < ActiveRecord::Migration[5.1]
  def change
    create_table :cfr_file_types do |t|
      t.string :label,               limit: MAX_LENGTH_OF_LABEL, index: true
      t.string :extensions_internal, limit: MAX_LENGTH_OF_NOTE

      t.timestamps null: false
    end
  end
end
