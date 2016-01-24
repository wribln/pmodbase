# (this is based on Justin Weiss' concept from his blog from Feb 17th, 2014)
# In order to provide filtering in a model, do the following:
# (1) In the respective model, define scopes for each of the variables to
#     allow filtering on
#       scope :status, -> (status) { where status: status }
#       scope :location, -> (location_id) { where location_id: location_id }
#       scope :starts_with, -> (name) { where("name LIKE ?", "#{name}%") }
#     Note: scopes must not have existing names, and parameters MUST
#     correspond to named scopes!
# (2) include this module in the model
#       include Filterable
# (3) in the controller#index, instead of
#       @items = Item.all
#     write
#       @items = Item.filter( filter_params)
#     and define the method filter_scopes to return a hash with the scope
#     information and all blank entries removed, e.g.
#       params.slice( :status, :location, :starts_with ).delete_if{ |key,value| value.blank? }
#     or better use the clean_up method
# =>    params.slice( :status, :location, :starts_with ).clean_up
# (4) in order to keep the original values for reference, leave the params
#     alone; if any modification on the values (e.g. for checkbox fields)
#     are needed, do NOT do it on the params but rather on the filter_scopes
#     to be returned by the filter_scopes method.

module Filterable
  extend ActiveSupport::Concern

  module ClassMethods

    # set scopes based on defined filter values, do not return any empty
    # values so the result is empty if no filters are set:

    def filter( filter_scopes )
      results = self.where( nil )
      filter_scopes.each do | key, value |
        results = results.public_send( key, value ) if value.present?
      end
      results
    end

  end

end

# extend Parameters class with clean_up: this removes all empty entries,
# including arrays with empty information

class ActionController::Parameters

  def clean_up
    self.delete_if do |key,value|
      if value.is_a? Enumerable
        value.empty? || !value.any? { |v| v.present? }
      else
        value.blank?
      end
    end
  end

end