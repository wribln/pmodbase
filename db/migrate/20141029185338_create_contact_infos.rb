class CreateContactInfos < ActiveRecord::Migration
  def change
    create_table :contact_infos do |t|
      t.string      :info_type,       limit: MAX_LENGTH_OF_INFORMATION_TYPE,  null: false
      t.string      :phone_no_fixed,  limit: MAX_LENGTH_OF_PHONE_NUMBER,      null: false, default: ""
      t.string      :phone_no_mobile, limit: MAX_LENGTH_OF_PHONE_NUMBER,      null: false, default: ""
      t.string      :department,      limit: MAX_LENGTH_OF_DEPARTMENT,        null: false, default: ""
      t.string      :detail_location, limit: MAX_LENGTH_OF_LOCATION_DETAIL,   null: false, default: ""
      t.belongs_to  :address, foreign_key: :true
      t.belongs_to  :person,  foreign_key: :true, null: false

      t.timestamps null: false
    end
  end
end
