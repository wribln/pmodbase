class CreatePcpCategories < ActiveRecord::Migration
  def change
    create_table :pcp_categories do |t|
      t.belongs_to  :c_group, null: false,  index: true
      t.belongs_to  :p_group, null: false,  index: true
      t.belongs_to  :c_owner, null: false,  index: true
      t.belongs_to  :p_owner, null: false,  index: true
      t.belongs_to  :c_deputy,              index: true
      t.belongs_to  :p_deputy,              index: true
      t.string      :label,   null: false, length: MAX_LENGTH_OF_LABEL
      t.text        :description

      t.timestamps null: false
    end
    add_foreign_key :pcp_categories, :groups, column: :c_group_id
    add_foreign_key :pcp_categories, :groups, column: :p_group_id
    add_foreign_key :pcp_categories, :accounts, column: :c_owner_id
    add_foreign_key :pcp_categories, :accounts, column: :p_owner_id
    add_foreign_key :pcp_categories, :accounts, column: :c_deputy_id
    add_foreign_key :pcp_categories, :accounts, column: :p_deputy_id
  end
end
