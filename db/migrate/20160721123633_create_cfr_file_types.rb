class CreateCfrFileTypes < ActiveRecord::Migration
  def change
    create_table :cfr_file_types do |t|
      t.string :label,     limit: MAX_LENGTH_OF_LABEL
      t.string :extensions, limit: MAX_LENGTH_OF_NOTE, null: false

      t.timestamps null: false
    end
  end
end
