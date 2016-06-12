class CreatePermission4Flows < ActiveRecord::Migration
  def change
    create_table :permission4_flows do |t|
      t.belongs_to  :account,     null: false, foreign_key: :true, index: :true
      t.belongs_to  :feature,     null: false, foreign_key: :true, index: :true
      t.integer     :workflow_id, null: false
      t.string      :label,     length: MAX_LENGTH_OF_LABEL
      t.string      :tasklist,  length: MAX_LENGTH_OF_TASKS_STRING

      t.timestamps null: false
    end
    add_index :permission4_flows, [ :feature_id, :workflow_id, :account_id ], unique: true, name: 'rfc_index'
  end
end
