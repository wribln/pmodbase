class CreateOrlTypes < ActiveRecord::Migration
  def change
    create_table :orl_types do |t|
      t.belongs_to  :o_group, null: false, index: true, foreign_key: true
      t.belongs_to  :r_group, null: false, index: true, foreign_key: true
      t.string      :label,   null: false, length: MAX_LENGTH_OF_LABEL

      t.timestamps null: false
    end
  end
end
