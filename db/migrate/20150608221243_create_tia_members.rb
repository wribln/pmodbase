class CreateTiaMembers < ActiveRecord::Migration[5.1]
  def change
    create_table :tia_members do |t|
      t.belongs_to  :account,   null: false,              index: true, foreign_key: :true
      t.belongs_to  :tia_list,  null: false,              index: true, foreign_key: :true
      t.boolean     :to_access, null: false, default: true
      t.boolean     :to_update, null: false, default: false

      t.timestamps              null: false
    end
  end
end
