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

  default_scope { order( code: :asc )}
  scope :as_abbr, ->  ( abbr ){ where( 'code LIKE ?', "#{ abbr }%" )}
  scope :as_desc, ->  ( desc ){ where( 'description LIKE ?', "%#{ desc }%" )}
  scope :ff_id, ->    ( id   ){ where id: id }
  scope :ff_abbr, ->  ( abbr ){ as_abbr( abbr ) }
  scope :ff_desc, ->  ( desc ){ as_desc( desc ) }

  def code=( text )
    write_attribute( :code, AppHelper.clean_up( text, MAX_LENGTH_OF_CODE ))
  end

  def description=( text )
    write_attribute( :description, AppHelper.clean_up( text, MAX_LENGTH_OF_DESCRIPTION ))
  end

end
