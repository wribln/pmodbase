class CreateServiceCodes < ActiveRecord::Migration[5.1]
  def change
    create_table :service_codes do |t|
      t.string  :code,    limit: MAX_LENGTH_OF_CODE, null: false, index: true
      t.string  :label,   limit: MAX_LENGTH_OF_LABEL, null: false
      t.boolean :active,   null: false, default: true
      t.boolean :master,   null: false, default: true
      t.boolean :standard, null: false, default: true
      t.boolean :heading,  null: false, default: false
      t.string  :note,  limit: MAX_LENGTH_OF_NOTE

      t.timestamps null: false
    end
  end
end
