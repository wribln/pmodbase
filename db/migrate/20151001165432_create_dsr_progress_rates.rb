class CreateDsrProgressRates < ActiveRecord::Migration
  def change
    create_table :dsr_progress_rates do |t|
      t.integer :document_progress, default: 0
      t.integer :prepare_progress,  default: 0
      t.integer :approve_progress, default: 0

      t.timestamps null: false
    end
  end
end
