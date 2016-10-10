class CreateIsrInterfaces < ActiveRecord::Migration
  def change
    create_table :isr_interfaces do |t|
      t.belongs_to  :l_group,         null: false, index: true
      t.belongs_to  :l_owner
      t.belongs_to  :l_deputy
      t.string      :l_signature,     limit: MAX_LENGTH_OF_ACCOUNT_NAME + MAX_LENGTH_OF_PERSON_NAMES
      t.belongs_to  :p_group
      t.belongs_to  :p_owner
      t.belongs_to  :p_deputy
      t.string      :p_signature,     limit: MAX_LENGTH_OF_ACCOUNT_NAME + MAX_LENGTH_OF_PERSON_NAMES
      t.string      :title,           limit: MAX_LENGTH_OF_TITLE
      t.string      :desc,            limit: MAX_LENGTH_OF_DESCRIPTION
      t.boolean     :safety_related,  default: false
      t.belongs_to  :cfr_record,      index: true, foreign_key: true
      t.integer     :if_level,        default: 0, null: false
      t.integer     :if_status,       default: 0, null: false
      t.integer     :current_status,  default: 0, null: false
      t.integer     :current_task,    default: 0, null: false

      t.timestamps null: false
    end
    add_foreign_key :isr_interfaces, :groups, column: :l_group_id
    add_foreign_key :isr_interfaces, :groups, column: :p_group_id
    add_foreign_key :isr_interfaces, :accounts, column: :l_owner_id
    add_foreign_key :isr_interfaces, :accounts, column: :l_deputy_id
    add_foreign_key :isr_interfaces, :accounts, column: :p_owner_id
    add_foreign_key :isr_interfaces, :accounts, column: :p_deputy_id
  end
end
