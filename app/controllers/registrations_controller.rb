class RegistrationsController < ApplicationController

  hobo_model_controller

  auto_actions :lifecycle, :edit, :update, :show
  auto_actions_for :owner, [:index]

  def do_register
    rrid = params[:registration][:registration_role_id]
    rr = RegistrationRole.find rrid
    if rr.operation != RegistrationRole::OperationType::DEFAULT
      hash = {:registration_role_id => rrid}
      hash.merge! :country_id=>current_user.country.id if current_user.country
      redirect_to :controller => rr.operation.downcase.pluralize,
                  :action => :enroll,
		  :enrollment => hash
      
    else
      do_creator_action :register
    end
  end
end
