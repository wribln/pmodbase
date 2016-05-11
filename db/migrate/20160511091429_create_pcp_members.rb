class CreatePcpMembers < ActiveRecord::Migration
  def change
    create_table :pcp_members do |t|
      t.belongs_to  :pcp_subject, null: false, index: true, foreign_key: true
      t.belongs_to  :account,     null: false, index: true, foreign_key: true
      t.integer     :pcp_group,   null: false
      t.boolean     :to_access,   null: false, default: true
      t.boolean     :to_update,   null: false, default: false

      t.timestamps                null: false
    end
    add_index :pcp_members, [ :pcp_subject_id, :account_id, :pcp_group ], unique: true, name: 'pcp_members_index'
    add_index :pcp_members, [ :pcp_subject_id, :pcp_group ], name: 'pcp_group_members'
  end
end
