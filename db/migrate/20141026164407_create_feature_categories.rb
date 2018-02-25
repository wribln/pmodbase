class CreateFeatureCategories < ActiveRecord::Migration[5.1]
  def change
    create_table :feature_categories do |t|
      t.string  :label, length: MAX_LENGTH_OF_LABEL, null: false, default: ''
      t.integer :seqno, null: false, default: 0

      t.timestamps null: false
    end
  end
end
