class CreateResponsibilities < ActiveRecord::Migration
  def change
    create_table :responsibilities do |t|
      t.string      :description, limit: MAX_LENGTH_OF_DESCRIPTION, null: false
      t.integer     :seqno,   default: 99
      t.belongs_to  :group,   foreign_key: :true, null: false
      t.belongs_to  :person,  foreign_key: :true

      t.timestamps null: false
    end
  end
end
