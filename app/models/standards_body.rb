require "./lib/assets/app_helper.rb"
class StandardsBody < ActiveRecord::Base
  include ApplicationModel
  include Filterable

  validates :code,
    length: { maximum: MAX_LENGTH_OF_CODE },
    presence: true

  validates :description,
    length: { maximum: MAX_LENGTH_OF_DESCRIPTION },
    presence: true

  set_trimmed :code, :description

  default_scope { order( code: :asc )}
  scope :as_abbr, ->  ( a ){ where( 'code LIKE ?', "#{ a }%" )}
  scope :as_desc, ->  ( d ){ where( 'description LIKE ?', "%#{ d }%" )}
  scope :ff_id, ->    ( i ){ where id: i }
  class << self;
    alias :ff_abbr :as_abbr
    alias :ff_desc :as_desc
  end

end
