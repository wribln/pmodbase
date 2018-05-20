require './lib/assets/app_helper.rb'
class SDocumentLog < ActiveRecord::Base
  include ApplicationModel
  include Filterable

  belongs_to :account, -> { readonly }
  belongs_to :group,   -> { readonly }

  before_save do
    self.doc_id = create_siemens_doc_id
    self.set_nil_default( :author_date, Date.today )
  end

  validates :group, :account,
    presence: true

  validates :receiver_group,
    :function_code,
    :service_code,
    :product_code,
    :location_code,
    :phase_code,
    :revision_code,
    length: { maximum: MAX_LENGTH_OF_CODE }

  validates :dcc_code,
    presence: true,
    length: { maximum: MAX_LENGTH_OF_CODE }

  validates :author_date,
    date_field: { presence: false }

  validates :doc_id,
    length: { maximum: MAX_LENGTH_OF_DOC_ID_S }

  validate :at_least_one_given
  validate :all_codes_valid

  scope :revorder, -> { order( id: :desc )}
  scope :inorder, -> { order( id: :asc  )}
  scope :ff_srec, -> ( i ){ where id: i }
  scope :ff_sdic, -> ( s ){ where( 'doc_id LIKE ? ESCAPE \'\\\'', "%#{ sanitize_sql_like( s, '\\' )}%" )}
  scope :ff_titl, -> ( t ){ where( 'title LIKE ?', "%#{ t }%" )}

  # check that at least one of the attribute codes are given

  def at_least_one_given
    errors.add( :base, I18n.t( 's_document_logs.msg.at_least_one' )) \
      if function_code.blank? && service_code.blank? && product_code.blank? && phase_code.blank?
  end

  # make sure all specified codes exist (note: they might be passed
  # other than through the standard view!)

  def all_codes_valid
    msg = I18n.t( 's_document_logs.msg.invalid_code' )
    errors.add( :function_code, msg ) \
      unless function_code.blank? || errors.exclude?( :function_code ) && FunctionCode.where( code: function_code ).exists?
    errors.add( :service_code, msg ) \
      unless service_code.blank? || errors.exclude?( :service_code ) && ServiceCode.where( code: service_code ).exists?
    errors.add( :product_code, msg ) \
      unless product_code.blank? || errors.exclude?( :product_code ) && ProductCode.where( code: product_code ).exists?
    errors.add( :phase_code, msg ) \
      unless phase_code.blank? || errors.exclude?( :phase_code ) && SiemensPhase.where( code: phase_code ).exists?
    errors.add( :location_code, msg ) \
      unless location_code.blank? || errors.exclude?( :location_code ) && LocationCode.where( code: location_code ).exists?
    errors.add( :dcc_code, msg ) \
      unless dcc_code.blank? || errors.exclude?( :dcc_code ) && DccCode.where( code: dcc_code ).exists?
  end

  # create siemens document code

  def create_siemens_doc_id
    '' << SITE_ID << '(' << group.code << 
    ( receiver_group.blank? ? '' : ')' << receiver_group )<<
    function_code.to_s <<
    service_code.to_s << 
    product_code.to_s <<
    location_code.to_s <<
    phase_code.to_s <<
    dcc_code <<
    ( author_date.nil? ? '' : '_' << author_date.strftime( '%Y%m%d' )) <<
    '_TDD' << sprintf( "%5.5d", id || 0 ) <<
    ( revision_code.blank? ? '' : '_' << revision_code )
  end

  # return title and doc id for a given id, returns nil if given id
  # is not found

  def self.get_title_and_doc_id( i )
    where( id: i ).pluck( :title, :doc_id ).first
  end

  # this returns the doc_id with the version attribute appended
  # using the correct syntax

  def self.combine_doc_id_and_version( doc_id, version )
    doc_id.to_s << '_' << version.to_s
  end

  # for error checking

  MAX_LENGTH_OF_DOC_ID = MAX_LENGTH_OF_DOC_ID_S.freeze

end
