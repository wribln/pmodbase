require './lib/assets/app_helper.rb'
class Abbreviation < ActiveRecord::Base
  include ApplicationModel
  include Filterable
  
  before_save :set_sort_code

  validates :code,
    length: { maximum: MAX_LENGTH_OF_CODE },
    presence: true

  validates :description,
    length: { maximum: MAX_LENGTH_OF_DESCRIPTION },
    presence: true

  validates :sort_code,
    length: { maximum: MAX_LENGTH_OF_CODE }

  default_scope { order( sort_code: :asc )}
  scope :as_abbr, ->  ( a ){ where( 'code LIKE ?', "#{ a }%" )}
  scope :as_desc, ->  ( d ){ where( 'description LIKE ?', "%#{ d }%" )}
  scope :ff_id, ->    ( i ){ where id: i }
  class << self; 
    alias :ff_code :as_abbr
    alias :ff_desc :as_desc
  end

  def code=( text )
    write_attribute( :code, AppHelper.clean_up( text ))
  end

  def sort_code=( text )
    write_attribute( :sort_code, AppHelper.clean_up( text ))
  end

  def description=( text )
    write_attribute( :description, AppHelper.clean_up( text ))
  end

  # use this to automatically create the sort code from the abbreviation:
  # remove punctuation characters and map all uppercase characters to lowercase;
  # if the remaining string is empty, the sort code will be the code with each
  # character replaced by a questionmark

  def set_sort_code
    if self.sort_code.blank?
      self.sort_code = code.delete( '^a-zA-Z0-9' ).downcase
      if self.sort_code.blank?
        self.sort_code = code.gsub( /./, '?' )
      end
    end
  end

end
