require "./lib/assets/app_helper.rb"
class GlossaryItem < ActiveRecord::Base
  include ApplicationModel
  include Filterable
  include ReferenceCheck

  belongs_to :reference, -> { readonly }, inverse_of: :glossary_items

  validates :term,
    length: { maximum: MAX_LENGTH_OF_TERM },
    presence: true

  validates :code,
    length: { maximum: MAX_LENGTH_OF_CODE }

  validate :given_reference_exists

  default_scope { order( term: :asc )}
  scope :as_abbr, ->  ( a ){ where( 'code LIKE ?', "#{ a }%" )}
  scope :as_desc, ->  ( d ){ where( '(code IS NOT NULL) AND (term LIKE ?)', "%#{ d }%" )}
  scope :ff_id, ->    ( i ){ where id: i }
  scope :ff_code, ->  ( a ){ as_abbr( a )}
  scope :ff_term, ->  ( t ){ where( 'term LIKE ?', "%#{ t }%" )}
  scope :ff_desc, ->  ( d ){ where( 'description LIKE ?', "%#{ d }%" )}
  scope :ff_ref,  ->  ( r ){ where( r == '0' ? 'reference_id IS NULL' : 'reference_id = ?', r )}

  def term=( text )
    write_attribute( :term, AppHelper.clean_up( text ))
  end

  def code=( text )
    write_attribute( :code, AppHelper.clean_up( text ))
  end

  def reference_with_id
    assoc_text_and_id( :reference, :code )
  end

end
