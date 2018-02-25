class CreateCountryNames < ActiveRecord::Migration[5.1]
  def change
    create_table :country_names do |t|
      t.string :code,  limit: MAX_LENGTH_OF_CODE,  null: false, index: true, unique: true
      t.string :label, limit: MAX_LENGTH_OF_LABEL, null: false
#      t.string :common_name, limit: MAX_LENGTH_OF_LABEL, null: false # replaces label, for common name of country
#      t.string :full_name, limit: MAX_LENGTH_OF_LABEL                # complete official name of country
      t.timestamps null: false
    end
  end
end
