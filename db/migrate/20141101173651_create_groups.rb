class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string     :code,  limit: MAX_LENGTH_OF_CODE,  null: false, default: "", index: true
      t.string     :label, limit: MAX_LENGTH_OF_LABEL, null: false, default: ""
      t.string     :notes, limit: MAX_LENGTH_OF_NOTE
      t.integer    :seqno, default: 0
      t.belongs_to :group_category, null: false

      t.timestamps null: false
    end
  end
end
