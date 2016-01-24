module ChangeRequestsHelper

  # to be called from the index page of a feature

  def link_to_cr( title, feature_id, details = nil )
    link_to title, add_my_change_request_path(
      feature_id: feature_id, 
      detail: details.nil? ? controller.controller_name : details ), 
      { target: controller.controller_name == 'base' ? "_blank" : "_self" }
  end 

end