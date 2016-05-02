class CreatePcpComments < ActiveRecord::Migration
  def change
    create_table :pcp_comments do |t|
      t.belongs_to  :pcp_item, index: true, foreign_key: true
      t.belongs_to  :pcp_step, index: true, foreign_key: true
      t.string      :description, limit: MAX_LENGTH_OF_DESCRIPTION
      t.string      :author,      limit: MAX_LENGTH_OF_ACCOUNT_NAME + MAX_LENGTH_OF_PERSON_NAMES
      t.boolean     :public, default: true

      t.timestamps null: false
    end
  end
end
