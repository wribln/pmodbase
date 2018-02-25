# use this class to add foreign keys at the end of migrations
# as MySql does not permit forward referencing of foreign keys :-(

class CreateForeignKeys < ActiveRecord::Migration[5.1]
  add_foreign_key :pcp_subjects, :cfr_records, column: :cfr_record_id
end