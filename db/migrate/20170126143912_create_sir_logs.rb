class CreateSirLogs < ActiveRecord::Migration
  def change
    create_table :sir_logs do |t|
      t.string :label, limit: MAX_LENGTH_OF_LABEL
      t.string :desc,  limit: MAX_LENGTH_OF_DESCRIPTION

      t.timestamps null: false
    end
  end
end
