class CreateDsrProgressRates < ActiveRecord::Migration
  def change
    create_table :dsr_progress_rates do |t|
      t.integer :document_progress, default: 0
      t.integer :prepare_progress,  default: 0
      t.integer :approve_progress, default: 0

      t.timestamps null: false
    end
    
    # I will start adding records with id = 0 ...
    # this is no problem with sqlite but mysql needs extra handling

    if Rails.env.production? then
      execute 'ALTER TABLE dsr_progress_rates AUTO_INCREMENT = 0;'
    end
  end
end
