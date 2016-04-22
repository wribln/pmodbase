require './lib/assets/app_helper.rb'
class CountryName < ActiveRecord::Base
  include ApplicationModel
  include Filterable

  has_many :region_names, dependent: :destroy, inverse_of: :country_name
  has_many :holidays,     dependent: :destroy, inverse_of: :country_name

  validates :code,
    uniqueness: true,
    length: { maximum: MAX_LENGTH_OF_CODE },
    presence: true

  validates :label,
    length: { maximum: MAX_LENGTH_OF_LABEL },
    presence: true

  default_scope { order( code: :asc )}
  scope :as_abbr, ->  ( a ){ where( 'code  LIKE ?',  "#{ a }%" )}
  scope :as_desc, ->  ( l ){ where( 'label LIKE ?', "%#{ l }%" )}
  scope :ff_id, ->    ( i ){ where id: i }
  class << self;
    alias :ff_code  :as_abbr
    alias :ff_label :as_desc
  end


  def code=( text )
    write_attribute( :code, AppHelper.clean_up( text, MAX_LENGTH_OF_CODE ))
  end

  def label=( text )
    write_attribute( :label, AppHelper.clean_up( text, MAX_LENGTH_OF_LABEL ))
  end

end
