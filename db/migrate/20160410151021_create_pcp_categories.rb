class CreatePcpCategories < ActiveRecord::Migration
  def change
    create_table :pcp_categories do |t|
      t.belongs_to  :c_group, null: false,  index: true, foreign_key: true
      t.belongs_to  :p_group, null: false,  index: true, foreign_key: true
      t.belongs_to  :c_owner, null: false,  index: true, foreign_key: true
      t.belongs_to  :p_owner, null: false,  index: true, foreign_key: true
      t.belongs_to  :c_deputy,              index: true, foreign_key: true
      t.belongs_to  :p_deputy,              index: true, foreign_key: true
      t.string      :label,   null: false, length: MAX_LENGTH_OF_LABEL

      t.timestamps null: false
    end
  end
end
