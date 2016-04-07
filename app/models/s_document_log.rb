require './lib/assets/app_helper.rb'
class SDocumentLog < ActiveRecord::Base
  include ApplicationModel
  include Filterable
  include AccountCheck
  include GroupCheck

  belongs_to :account, -> { readonly }
  belongs_to :group,   -> { readonly }

  before_save do
    self.siemens_doc_id = create_siemens_doc_id
    self.set_default!( :author_date, Date.today )
  end

  validates :group_id,
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

  validates :siemens_doc_id,
    length: { maximum: MAX_LENGTH_OF_DOC_ID_S }

  validate :given_account_exists
  validate :given_group_exists
  validate :at_least_one_given
  validate :all_codes_valid

  scope :reverse, -> { order( id: :desc )}
  scope :inorder, -> { order( id: :asc  )}
  scope :ff_srec, -> ( id   ){ where id: id }
  scope :ff_sdic, -> ( sdic ){ where( 'siemens_doc_id LIKE ? ESCAPE \'\\\'', "%#{ sanitize_sql_like( sdic, '\\' )}%" )}
  scope :ff_titl, -> ( titl ){ where( 'title LIKE ?', "%#{ titl }%" )}

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
    '' << SITE_NAME << '(' << group.code << 
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

end
