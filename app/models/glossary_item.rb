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
  scope :as_abbr, ->  ( abbr ){ where( 'code LIKE ?', "#{ abbr }%" )}
  scope :as_desc, ->  ( desc ){ where( '(code IS NOT NULL) AND (term LIKE ?)', "%#{ desc }%" )}
  scope :ff_id, ->    ( id   ){ where id: id }
  scope :ff_code, ->  ( abbr ){ as_abbr( abbr )}
  scope :ff_term, ->  ( term ){ where( 'term LIKE ?', "%#{ term }%" )}
  scope :ff_desc, ->  ( desc ){ where( 'description LIKE ?', "%#{ desc }%" )}
  scope :ff_ref,  ->  ( ref  ){ where( ref == '0' ? 'reference_id IS NULL' : 'reference_id = ?', ref )}

  def term=( text )
    write_attribute( :term, AppHelper.clean_up( text, MAX_LENGTH_OF_TERM ))
  end

  def code=( text )
    write_attribute( :code, AppHelper.clean_up( text, MAX_LENGTH_OF_CODE ))
  end

  def reference_with_id
    assoc_text_and_id( :reference, :code )
  end

end
