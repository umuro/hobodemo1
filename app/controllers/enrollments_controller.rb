class EnrollmentsController < ApplicationController

  hobo_model_controller

  auto_actions :lifecycle, :edit, :update
  auto_actions_for :owner, [:index]

# FIXME: delete redirect_to_event when merging uddin's returning forms
#   def update
#     hobo_update do
#       redirect_to_event(params[:id])
#     end
#   end
#
# FIXME: SOLVE IT IN REGISTER BUTTON
#   def enroll
#     if current_user.signed_up?
#       creator_page_action :enroll
#     else
#       redirect_to user_login_path
#     end
#   end
# 
#   def do_reject
#     do_transition_action :reject do
#       redirect_to_event(params[:id])
#     end
#   end
# 
#   def do_accept
#     do_transition_action :accept do
#       redirect_to_event(params[:id])
#     end
#   end
#   
#   private
# 
#     def redirect_to_event(enrollment_id)
#       enrollment = Enrollment.find(enrollment_id)
#       event_id = enrollment.event_id
#       redirect_to event_path :id=>event_id      
#     end
  
end