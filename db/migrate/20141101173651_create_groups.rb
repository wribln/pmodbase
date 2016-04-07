class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string     :code,  limit: MAX_LENGTH_OF_CODE,  null: false, default: "", index: true
      t.string     :label, limit: MAX_LENGTH_OF_LABEL, null: false, default: ""
      t.string     :notes, limit: MAX_LENGTH_OF_NOTE
      t.integer    :seqno, default: 0
      t.belongs_to :group_category, null: false
      t.references :sub_group_of, index: true
      t.boolean    :participating, default: true
      t.boolean    :s_sender_code, default: true
      t.boolean    :s_receiver_code, default: true
      t.boolean    :active, default: true
      t.boolean    :standard, default: true

      t.timestamps null: false
    end
  end
end
