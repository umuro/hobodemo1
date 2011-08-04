class FleetRacesController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => :index
  auto_actions_for :race, [:index, :new, :create]
  auto_actions_for :course_area, [:index] #mobile

  smart_form_setup

  show_action :flags do #mobile 
    hobo_show
    @flags = @this.flags
  end

  show_action :boats do #mobile #TODO should be Boat.index_for_fleet_race
    hobo_show
    @boats = @this.boats
  end

  def create_for_race
    hobo_create_for :race do |format|
      if valid?
        if this.copy_assignments_from
          this.copy_assignments_from.enrollments.each do |enrollment|
            frm = FleetRaceMembership.new
            frm.fleet_race = this
            frm.enrollment = enrollment
            frm.save
          end
        end
        respond_to do |wants|
          wants.html { redirect_after_submit(:redirect=>session['HTTP_REFERER']) }
          wants.js   { index_for_race }
        end
      else
      end
        respond_to do |wants|
		  # errors is used by the translation helper, ht, below.
		  errors = this.errors.full_messages.join("\n")
          wants.html { re_render_form('new_for_race') }
          wants.js   { render(:status => 500,
              :text => ht( :"#{this.class.name.pluralize.underscore}.messages.create.error", :errors=>errors,:default=>["Couldn't create the #{this.class.name.titleize.downcase}.\n #{errors}"])
              )}
        end
    end
  end
end
