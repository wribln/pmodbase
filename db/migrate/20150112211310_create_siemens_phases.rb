class CreateSiemensPhases < ActiveRecord::Migration[5.1]
  def change
    create_table :siemens_phases do |t|
      t.string :code,     limit: MAX_LENGTH_OF_CODE,  null: false
      t.string :label_p,  limit: MAX_LENGTH_OF_LABEL
      t.string :label_m,  limit: MAX_LENGTH_OF_LABEL

      t.timestamps null: false
    end
  end
end
