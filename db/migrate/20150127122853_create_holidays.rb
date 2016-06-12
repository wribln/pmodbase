class CreateHolidays < ActiveRecord::Migration
  def change
    create_table :holidays do |t|
      t.date        :date_from,     null: false, index: true
      t.date        :date_until,    null: false
      t.integer     :year_period,   null: false, index: true
      t.belongs_to  :country_name,  null: false, index: true, foreign_key: :true
      t.belongs_to  :region_name,   null: true,               foreign_key: :true
      t.string      :description, limit: MAX_LENGTH_OF_DESCRIPTION
      t.integer     :work,          null: false, default: 0

      t.timestamps  null: false
    end
  end
end
