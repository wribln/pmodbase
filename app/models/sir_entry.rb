class SirEntry < ActiveRecord::Base
  belongs_to :sir_item
  belongs_to :group
  belongs_to :parent,   class_name: 'SirEntry'
  has_one    :response, ->{ where rec_type: 2 }, class_name: 'SirEntry', foreign_key: 'parent_id'
end
