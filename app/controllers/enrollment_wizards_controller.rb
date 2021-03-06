class EnrollmentWizardsController < ApplicationController

  hobo_model_controller

  auto_actions :lifecycle, :show

  def walk_in
    creator_page_action :walk_in do
      this.email_address ||=""
      false
    end
  end
  def do_walk_in
      do_creator_action :walk_in do
	  this.applicant ||= User.find_by_email_address(this.email_address)
	  unless this.applicant
	    this.applicant = User::Lifecycle.invite(current_user, :email_address => this.email_address)
	    flash_notice "New user invited..."
	  end
	  this.destroy_others
	  this.owner ||= current_user
	  this.save
	  redirect_to object_url(this, :register)
      end
  end

  def register
    transition_page_action :register if params[:id]
    creator_page_action :register unless params[:id]
  end
  
  def do_register
    rrid = attribute_parameters[:registration_role_id]
    rr = RegistrationRole.find rrid
    if rr.operation == RegistrationRole::OperationType::DEFAULT
      r = Registration::Lifecycle.register(current_user, attribute_parameters)
      if r.valid?
	flash_notice("Your registration request is successfully sent to #{rr.event}")
	redirect_to object_url(rr.event)
      else
	re_render_form(:register)
      end
    else
      if params[:id]
	do_transition_action :register do
	    redirect_to object_url(this, this.lifecycle.state_name, :on_cancel=>object_url(this.event))
	    false
	end
      else
	do_creator_action :register do
	    this.destroy_others
	    redirect_to object_url(this, this.lifecycle.state_name, :on_cancel=>object_url(this.event))
	    false
	end
      end
    end
  end

  def revise
    do_revise
  end
  def do_revise
      do_creator_action :revise do
	  this.registration_role = this.enrollment.registration_role
	  this.boat = this.enrollment.boat
	  this.crew = this.enrollment.crew
	  this.country = this.enrollment.country
	  this.applicant = this.enrollment.owner

	  this.owner = current_user
	  this.destroy_others
	  this.save
	redirect_to object_url(this, this.lifecycle.state_name, :on_cancel=>object_url(this.event)) if valid?
	false
      end
  end
  
  def edit_profile
    transition_page_action :edit_profile do
      p = this.applicant.user_profile
      unless p
	p = UserProfile.new :owner=>this.applicant
	p.save(false)
      end
      redirect_to object_url(p, :edit, :on_cancel=>object_url(this.event), :redirect=>object_url(this, :edit_profile_after, :on_cancel=>object_url(this.event)))
    end
  end
  
  def edit_profile_after
    do_edit_profile_after
  end

  
  def do_edit_profile_after
    do_transition_action :edit_profile_after do
	redirect_to object_url(this, :select_boat, :on_cancel=>object_url(this.event))
	false
    end
  end

  def do_select_boat
    do_transition_action :select_boat do
	redirect_to object_url(this, :edit_equipment, :on_cancel=>object_url(this.event))
	false
    end
  end

  def create_boat
    transition_page_action :create_boat do
      b = Boat.new(:owner_id=>this.applicant.id, :sail_number=>'')
      b.save(false)
      this.boat = b; this.save
      redirect_to object_url(b, :edit, :on_cancel=>object_url(this.event), :redirect=>object_url(this, :create_boat_after, :on_cancel=>object_url(this.event))) if valid?
    end
  end

  def create_boat_after
    do_create_boat_after
  end

  def do_create_boat_after
    do_transition_action :create_boat_after do
	redirect_to object_url(this, :edit_equipment, :on_cancel=>object_url(this.event))
	false
    end
  end

  def edit_equipment
    transition_page_action :edit_equipment do
      redirect_to object_url(this.boat, :edit_equipment, :on_cancel=>object_url(this.event), :redirect=>object_url(this, :edit_equipment_after, :on_cancel=>object_url(this.event)))
    end
  end

  def edit_equipment_after
    do_edit_equipment_after
  end

  def do_edit_equipment_after
    do_transition_action :edit_equipment_after do
	redirect_to object_url(this, :select_crew, :on_cancel=>object_url(this.event))
	false
    end
  end

#   def select_crew
#     debugger
#     transition_page_action :select_crew
#   end
  
  def do_select_crew
    do_transition_action :select_crew do
	redirect_to object_url(this, :select_country, :on_cancel=>object_url(this.event))
	false
    end
  end

  def do_select_country
    do_transition_action :select_country do
	redirect_to object_url(this, :apply, :on_cancel=>object_url(this.event))
	false
    end
  end

  def do_apply
    do_transition_action :apply do

	unless this.enrollment
	  this.enrollment = Enrollment::Lifecycle.enroll(current_user, {:registration_role=>this.registration_role, :boat=>this.boat, :crew=>this.crew, :country=>this.country})
	  flash_notice "Your registration request has been success fully submitted to #{this.registration_role.event}" if this.enrollment.valid?
	else
	  this.enrollment.registration_role = this.registration_role
	  this.enrollment.boat = this.boat
	  this.enrollment.crew = this.crew
	  this.enrollment.country = this.country
	  this.enrollment.save
	  flash_notice "Changes saved..." if this.enrollment.valid?
	end
	    unless this.enrollment.valid?
	      flash[:error]=  this.enrollment.errors
	      re_render_form(:apply)
	    else
	      this.destroy
	      redirect_to object_url(this.event)
	    end
	false
    end
  end

end
