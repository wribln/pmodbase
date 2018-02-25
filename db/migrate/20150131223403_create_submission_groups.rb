class CreateSubmissionGroups < ActiveRecord::Migration[5.1]
  def change
    create_table :submission_groups do |t|
      t.string :code,         limit: MAX_LENGTH_OF_CODE,          null: false, index: true
      t.string :label,        limit: MAX_LENGTH_OF_LABEL

      t.timestamps null: false
    end
  end
end
