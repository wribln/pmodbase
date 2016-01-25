class CreateDsrProgressRates < ActiveRecord::Migration
  def change
    create_table :dsr_progress_rates, { id: false } do |t|
      t.integer :id, null: false
      t.integer :document_progress, default: 0
      t.integer :prepare_progress,  default: 0
      t.integer :approve_progress, default: 0

      t.timestamps null: false
    end
    add_index :dsr_progress_rates, :id, unique: true
  end
end
