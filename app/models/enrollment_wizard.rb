class EnrollmentWizard < ActiveRecord::Base

  hobo_model # Don't put anything above this
  include EventLocalTime

  fields do
    timestamps
  end

  belongs_to :owner,  :class_name => "User", :creator => true
  belongs_to :registration_role
  belongs_to :applicant, :class_name => "User"
  belongs_to :boat
  belongs_to :crew
  belongs_to :country  
  belongs_to :enrollment
  attr_accessor :email_address

  delegate :user_profile, :to=>:applicant
  delegate :event, :event_id, :to=>:registration_role
      
  lifecycle do
    #Remember that owner is set to be the creator

    EDIT_STATES = :edit_profile, :edit_profile_after, :select_boat, :create_boat, :edit_equipment, :edit_equipment_after, :select_crew, :select_country, :apply
    
    state :invite_user, :register, *EDIT_STATES
    
    create :register,	  :params => [:registration_role, :applicant, :owner_id],
	:available_to => "User",
	:become=>:edit_profile

    create :walk_in,	:params=>[:email_address, :registration_role],
	:available_to => "acting_user if acting_user.any_organization_admin?",
	:become=>:register

    create :revise,	:params=>[:enrollment],
	:available_to => "User",
	:become=>:edit_profile

    transition :register, {:register=>:edit_profile},
	:params=>[:registration_role, :applicant],
	:available_to=>:owner

    
    transition :edit_profile, {EDIT_STATES=>:edit_profile},
	:available_to=>:owner
    transition :edit_profile_after, {EDIT_STATES=>:select_boat},
	:available_to=>:owner

    transition :select_boat, {EDIT_STATES=>:edit_equipment},
	:params=>[:boat],
	:available_to=>:owner

    transition :create_boat, {EDIT_STATES=>:create_boat},
	:available_to=>:owner    
    transition :create_boat_after, {EDIT_STATES=>:edit_equipment},
	:available_to=>:owner
    
    transition :edit_equipment, {EDIT_STATES=>:edit_equipment},
	:available_to=>:owner
    transition :edit_equipment_after, {EDIT_STATES=>:select_crew},
	:available_to=>:owner

    transition :select_crew, {EDIT_STATES=>:select_country},
	:params=>[:crew],
	:available_to=>:owner

    transition :select_country, {EDIT_STATES=>:apply},
	:params=>[:country],
	:available_to=>:owner
    
    transition :apply, {:apply=>:apply},
	:available_to=>:owner
    transition :restart, {:apply=>:edit_profile},
	:available_to=>:owner
    
  end

  def name
    applicant.try(:last_name) or applicant.try(:email_address) or "new"
  end

  def destroy_others
    return unless owner
    others = owner.enrollment_wizards - [self]
    others.*.destroy
  end

  # --- Permissions --- #

  def create_permitted?
    acting_user.administrator?
  end

  def update_permitted?
    acting_user.administrator?
  end

  def destroy_permitted?
    acting_user.administrator?
  end

  def view_permitted?(field)
    true
  end

end
