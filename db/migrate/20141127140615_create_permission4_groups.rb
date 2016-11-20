class CreatePermission4Groups < ActiveRecord::Migration
  def change
    create_table :permission4_groups do |t|
      t.belongs_to :account,    null: false
      t.belongs_to :feature,    null: false
      t.belongs_to :group,      null: false
      t.integer    :to_index,   null: false, default: 0
      t.integer    :to_create,  null: false, default: 0
      t.integer    :to_read,    null: false, default: 0
      t.integer    :to_update,  null: false, default: 0
      t.integer    :to_delete,  null: false, default: 0

      t.timestamps null: false
    end
    add_index :permission4_groups, [ :account_id, :feature_id, :group_id ], unique: true, name: 'afg_index'
  end
end
