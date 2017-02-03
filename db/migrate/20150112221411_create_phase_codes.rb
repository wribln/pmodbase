class CreatePhaseCodes < ActiveRecord::Migration
  def change
    create_table :phase_codes do |t|
      t.string     :code,  limit: MAX_LENGTH_OF_CODE,  null: false
      t.string     :label, limit: MAX_LENGTH_OF_LABEL, null: false
      t.string     :acro,  limit: MAX_LENGTH_OF_CODE
      t.belongs_to :siemens_phase, index: :true, foreign_key: :true, null: false
      t.integer    :level, default: 0

      t.timestamps null: false
    end
    add_index :phase_codes, :code, order: { code: :asc }, name: 'phase_codes_std_order'
  end
end
