require './lib/assets/app_helper.rb'
class ADocumentLog < ActiveRecord::Base
  include ApplicationModel
  include ActiveModelErrorsAdd
  include Filterable

  belongs_to :account, -> { readonly }

  before_save do
    self.doc_id = create_alt_doc_id
    self.set_default_for_blank( :author_date, Date.today )
  end

  validates :a1_code, :a2_code, :a3_code, :a4_code, :a5_code, :a6_code, :a7_code, :a8_code,
    presence: true,
    length: { maximum: MAX_LENGTH_OF_CODE }

  validates :doc_id,
    length: { maximum: MAX_LENGTH_OF_DOC_ID_A }

  validates :title,
    length: { maximum: MAX_LENGTH_OF_TITLE }

  validates :account,
    presence: true

  validate :all_codes_valid

  scope :reverse, -> { order( id: :desc )}
  scope :inorder, -> { order( id: :asc  )}
  scope :ff_srec, -> ( id   ){ where id: id }
  scope :ff_adic, -> ( adic ){ where( 'doc_id LIKE ?', "%#{ adic }%" )}
  scope :ff_titl, -> ( titl ){ where( 'title LIKE ?', "%#{ titl }%" )}

  # make sure all codes entered are valid

  def all_codes_valid
    msg = I18n.t( 'a_document_logs.msg.invalid_code' )
    errors.add( :a1_code, msg ) unless errors.exclude?( :a1_code ) && A1Code.where( code: a1_code ).exists?
    errors.add( :a2_code, msg ) unless errors.exclude?( :a2_code ) && A2Code.where( code: a2_code ).exists?
    errors.add( :a3_code, msg ) unless errors.exclude?( :a3_code ) && A3Code.where( code: a3_code ).exists?
    errors.add( :a4_code, msg ) unless errors.exclude?( :a3_code ) && errors.exclude?( :a4_code ) &&
        A4Code.where( code: A4Code.join_codes( a3_code, a4_code )).exists?
    errors.add( :a5_code, msg ) unless errors.exclude?( :a5_code ) && A5Code.where( code: a5_code ).exists?
    errors.add( :a6_code, msg ) unless errors.exclude?( :a6_code ) && A6Code.where( code: a6_code ).exists?
    errors.add( :a7_code, msg ) unless errors.exclude?( :a7_code ) && A7Code.where( code: a7_code ).exists?
    errors.add( :a8_code, msg ) unless errors.exclude?( :a8_code ) && A8Code.where( code: a8_code ).exists?
  end

  # create document code

  def create_alt_doc_id
    String.new << 
    a1_code << '-' <<
    a2_code << '-' <<
    a3_code << '-' <<
    a4_code << '-' <<
    a5_code << '-' <<
    a6_code << '-' <<
    a7_code << '-' <<
    a8_code << '-' <<
    sprintf( "%5.5d", id || 0 )
  end

  # return title and doc id for a given id

  def self.get_title_and_doc_id( i )
    where( id: i ).pluck( :title, :doc_id ).first
  end

  # this returns the doc_id with the version attribute appended
  # using the correct syntax

  def self.combine_doc_id_and_version( doc_id, version )
    doc_id.to_s << '-' << version.to_s
  end

  # for error checking

  MAX_LENGTH_OF_DOC_ID = MAX_LENGTH_OF_DOC_ID_A.freeze

end
