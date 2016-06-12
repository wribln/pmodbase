class CreateProgrammeActivities < ActiveRecord::Migration
  def change
    create_table :programme_activities do |t|
      t.string  :project_id,      length: MAX_LENGTH_OF_PROGRAMME_IDS
      t.string  :activity_id,     length: MAX_LENGTH_OF_PROGRAMME_IDS
      t.string  :activity_label,  length: MAX_LENGTH_OF_DESCRIPTION
      t.date    :start_date
      t.date    :finish_date

      t.timestamps null: false
    end
  end
end
