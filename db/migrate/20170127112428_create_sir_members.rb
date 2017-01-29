class CreateSirMembers < ActiveRecord::Migration
  def change
    create_table :sir_members do |t|
      t.belongs_to  :account,   null: false,              index: true, foreign_key: :true
      t.belongs_to  :sir_log,   null: false,              index: true, foreign_key: :true
      t.boolean     :to_access, null: false, default: true
      t.boolean     :to_update, null: false, default: false

      t.timestamps null: false
    end
  end
end
