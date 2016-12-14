class CreateIsrAgreements < ActiveRecord::Migration
  def change
    create_table :isr_agreements do |t|
      t.belongs_to  :isr_interface,   null: false, index: true
      t.integer     :ia_type,         null: false, default: 0
      t.belongs_to  :l_group,         null: false, index: true
      t.belongs_to  :l_owner
      t.belongs_to  :l_deputy
      t.string      :l_signature,     limit: MAX_LENGTH_OF_ACCOUNT_NAME + MAX_LENGTH_OF_PERSON_NAMES
      t.datetime    :l_sign_time
      t.belongs_to  :p_group,         index: true
      t.belongs_to  :p_owner
      t.belongs_to  :p_deputy
      t.string      :p_signature,     limit: MAX_LENGTH_OF_ACCOUNT_NAME + MAX_LENGTH_OF_PERSON_NAMES
      t.datetime    :p_sign_time
      t.belongs_to  :cfr_record,      foreign_key: true
      t.text        :def_text
      t.integer     :ia_status,       default: 0, null: false
      t.integer     :current_status,  default: 0, null: false
      t.integer     :current_task,    default: 0, null: false
      t.belongs_to  :res_steps
      t.belongs_to  :val_steps
      t.integer     :ia_no,           null: false
      t.integer     :rev_no,          default: 0, null: false
      t.belongs_to  :based_on

      t.timestamps null: false
    end
    add_foreign_key :isr_agreements, :groups, column: :l_group_id
    add_foreign_key :isr_agreements, :groups, column: :p_group_id
    add_foreign_key :isr_agreements, :isr_agreements, column: :based_on_id
    add_foreign_key :isr_agreements, :isr_interfaces, column: :isr_interface_id
    add_foreign_key :isr_agreements, :tia_lists, column: :res_steps
    add_foreign_key :isr_agreements, :tia_lists, column: :val_steps
    add_foreign_key :isr_agreements, :accounts, column: :l_owner_id
    add_foreign_key :isr_agreements, :accounts, column: :l_deputy_id
    add_foreign_key :isr_agreements, :accounts, column: :p_owner_id
    add_foreign_key :isr_agreements, :accounts, column: :p_deputy_id
    add_index       :isr_agreements, [ :isr_interface_id, :ia_no, :rev_no ], 
                      order: { isr_interface_id: :asc, ia_no: :asc, rev_no: :desc }, 
                      unique: true, name: 'isa_default_order'
  end
end
