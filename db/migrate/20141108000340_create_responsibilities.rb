class CreateResponsibilities < ActiveRecord::Migration
  def change
    create_table :responsibilities do |t|
      t.string      :description, limit: MAX_LENGTH_OF_DESCRIPTION, null: false, default: ""
      t.integer     :seqno, default: 99
      t.belongs_to  :group, null: false
      t.belongs_to  :person, null: false, default: 0

      t.timestamps null: false
    end
  end
end
