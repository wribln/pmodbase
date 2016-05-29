class CreatePcpItems < ActiveRecord::Migration
  def change
    create_table :pcp_items do |t|
      t.belongs_to  :pcp_subject, index: true, foreign_key: true
      t.belongs_to  :pcp_step,    index: true, foreign_key: true
      t.integer     :seqno,       null: false
      t.string      :reference,   limit: MAX_LENGTH_OF_NOTE
      t.integer     :pub_assmt,   default: nil
# :new_assmt must have the same default value as :assessment
      t.integer     :new_assmt,   null: false, default: 0
# the following should/must be identical to those in PcpComment, except that the
# description is optional there and we have an additional public flag there
      t.text        :description, null: false
      t.string      :author,      limit: MAX_LENGTH_OF_ACCOUNT_NAME + MAX_LENGTH_OF_PERSON_NAMES
      t.integer     :assessment,  null: false, default: 0

      t.timestamps null: false
    end
    add_index :pcp_items, [ :pcp_subject_id, :id ], name: 'pcp_items_index'
  end
end
