class CreatePcpComments < ActiveRecord::Migration[5.1]
  def change
    create_table :pcp_comments do |t|
      t.belongs_to  :pcp_item, index: true, foreign_key: true
      t.belongs_to  :pcp_step, index: true, foreign_key: true
# the following should/must be identical to those in PcpItem, except that the
# :description is optional here and we have an additional :is_public flag
      t.text        :description
      t.string      :author,      limit: MAX_LENGTH_OF_ACCOUNT_NAME + MAX_LENGTH_OF_PERSON_NAMES
      t.integer     :assessment,  null: false, default: 0
      t.boolean     :is_public, default: false

      t.timestamps null: false
    end
    add_index :pcp_comments, [ :pcp_item_id, :pcp_step_id ], name: 'pcp_comments_index'
   end
end
