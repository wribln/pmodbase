class CreateIsrInterfaces < ActiveRecord::Migration
  def change
    create_table :isr_interfaces do |t|
      t.belongs_to  :l_group,         null: false, index: true
      t.string      :l_signature,     limit: MAX_LENGTH_OF_ACCOUNT_NAME + MAX_LENGTH_OF_PERSON_NAMES
      t.datetime    :l_sign_time
      t.belongs_to  :p_group,         index: true
      t.string      :p_signature,     limit: MAX_LENGTH_OF_ACCOUNT_NAME + MAX_LENGTH_OF_PERSON_NAMES
      t.datetime    :p_sign_time
      t.string      :title,           limit: MAX_LENGTH_OF_TITLE
      t.string      :desc,            limit: MAX_LENGTH_OF_DESCRIPTION
      t.boolean     :safety_related,  default: false
      t.belongs_to  :cfr_record,      foreign_key: true
      t.integer     :if_level,        default: 0, null: false
      t.integer     :if_status,       default: 0, null: false
      t.integer     :current_status,  default: 0, null: false
      t.integer     :current_task,    default: 0, null: false

      t.timestamps null: false
    end
    add_foreign_key :isr_interfaces, :groups, column: :l_group_id
    add_foreign_key :isr_interfaces, :groups, column: :p_group_id
    add_index :isr_interfaces, [ :l_group_id, :p_group_id ], name: 'isr_default_order'
  end
end
