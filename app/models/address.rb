require './lib/assets/app_helper.rb'
class Address < ActiveRecord::Base
  include ApplicationModel
  include Filterable

  validates :label,
    length: { maximum: MAX_LENGTH_OF_LABEL },
    presence: true,
    uniqueness: true

  validates :street_address,
    length: { maximum: MAX_LENGTH_OF_ADDRESS }

  validates :postal_address,
    length: { maximum: MAX_LENGTH_OF_ADDRESS }

  scope :ff_id,       -> ( id       ){ where id: id }
  scope :ff_label,    -> ( label    ){ where( 'label LIKE ?', "%#{ label }%" )}
  scope :ff_address,  -> ( address  ){ where( 'street_address LIKE :param OR postal_address LIKE :param', param: "%#{ address }%" )}

  # overwrite write accessors to ensure that text fields do not contain
  # any redundant blanks

  def label=( text )
    write_attribute( :label, AppHelper.clean_up( text ))
  end

  def street_address=( text )
    write_attribute( :street_address, AppHelper.clean_up( text ))
  end

  def postal_address=( text )
    write_attribute( :postal_address, AppHelper.clean_up( text ))
  end

  # display short label with id suffix

  def label_with_id
    text_and_id( :label )
  end

end
