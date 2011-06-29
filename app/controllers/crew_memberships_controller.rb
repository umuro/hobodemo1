class CrewMembershipsController < ApplicationController

  hobo_model_controller

  auto_actions :lifecycle

  #auto_actions :lifecycle exists but the corresponding "owner" actions are missing
  #auto_actions_for :crew, :lifecycle

  auto_actions_for :joined_crew, [:index, :new]

  smart_form_setup

  index_action :received do
    conditions = { :invitee_id => current_user }
    hobo_index CrewMembership, :conditions => conditions, :per_page => 10
  end

  # GP: to refactor following the suggestion in the article below as suggested by UO
  # http://ryandaigle.com/articles/2008/7/7/what-s-new-in-edge-rails-easy-join-table-conditions

  index_action :sent do
    crews_ids = Crew.find(:all, :conditions=> {:owner_id => current_user}).*.id
    conditions = { :joined_crew_id => crews_ids }
    hobo_index CrewMembership, :conditions => conditions, :per_page => 10
  end
  
#   def invite 
#     self.this = model.new attribute_parameters
#     #self.this = model.new params[:crew_membership]
#     creator_page_action :invite 
#   end


end
