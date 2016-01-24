class CreateFeatures < ActiveRecord::Migration
  def change
    create_table :features do |t|
      t.string      :code, limit: MAX_LENGTH_OF_CODE
      t.string      :label, limit: MAX_LENGTH_OF_LABEL
      t.integer     :seqno, default: 0
      t.integer     :access_level, default: 0
      t.integer     :control_level, default: 0
      t.integer     :no_workflows, default: 0
      t.belongs_to  :feature_category, null: false 

      t.timestamps null: false
    end
  end
end
