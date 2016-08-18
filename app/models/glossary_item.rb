require "./lib/assets/app_helper.rb"
class GlossaryItem < ActiveRecord::Base
  include ApplicationModel
  include ActiveModelErrorsAdd
  include Filterable

  belongs_to :reference, -> { readonly }, inverse_of: :glossary_items

  validates :term,
    length: { maximum: MAX_LENGTH_OF_TERM },
    presence: true

  validates :code,
    length: { maximum: MAX_LENGTH_OF_CODE }

  validates :reference,
    presence: true, if: Proc.new{ |me| me.reference_id.present? }

  default_scope { order( term: :asc )}
  scope :as_abbr, ->  ( a ){ where( 'code LIKE ?', "#{ a }%" )}
  scope :as_desc, ->  ( d ){ where( '(code IS NOT NULL) AND (term LIKE ?)', "%#{ d }%" )}
  scope :ff_id, ->    ( i ){ where id: i }
  scope :ff_code, ->  ( a ){ as_abbr( a )}
  scope :ff_term, ->  ( t ){ where( 'term LIKE ?', "%#{ t }%" )}
  scope :ff_desc, ->  ( d ){ where( 'description LIKE ?', "%#{ d }%" )}
  scope :ff_ref,  ->  ( r ){ where( r == '0' ? 'reference_id IS NULL' : 'reference_id = ?', r )}

  set_trimmed :term, :code

  def reference_with_id
    assoc_text_and_id( :reference, :code )
  end

end
