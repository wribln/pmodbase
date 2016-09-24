class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.string      :formal_name,   limit: MAX_LENGTH_OF_PERSON_NAMES
      t.string      :informal_name, limit: MAX_LENGTH_OF_PERSON_NAMES
      t.string      :email,         limit: MAX_LENGTH_OF_EMAIL_STRING,  null: false
      t.boolean     :involved,                                          null: false,  default: true, index: :true

      t.timestamps null: false
    end
  end
end
