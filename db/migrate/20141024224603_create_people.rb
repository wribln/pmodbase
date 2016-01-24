class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.string      :formal_name, :limit => MAX_LENGTH_OF_PERSON_NAMES, null: false, default: ""
      t.string      :informal_name, :limit => MAX_LENGTH_OF_PERSON_NAMES, null: false, default: ""
      t.string      :email, :limit => MAX_LENGTH_OF_EMAIL_STRING, null: false, default: ""
      t.boolean     :involved, null: false, default: true

      t.timestamps null: false
    end
  end
end
