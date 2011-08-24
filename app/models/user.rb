class User < ActiveRecord::Base

  hobo_user_model # Don't put anything above this
  has_etag

  fields do
    email_address :email_address, :login => true , :name=>true
    administrator :boolean, :default => false
    timestamps
  end
  set_default_order "email_address ASC"

  before_validation_on_create :already_signedup_check

  delegate :country, :to=>:user_profile
  delegate :first_name, :to=>:user_profile 
  delegate :last_name, :to=>:user_profile

  has_many :organization_admin_roles, :dependent=>:destroy
  has_many :organizations_as_admin, :through=>:organization_admin_roles, :source=>:organization

  has_many :event_spotter_roles, :dependent => :destroy
  has_many :events_as_spotter, :through => :event_spotter_roles, :source => :event, :conditions=>['end_time >= :current_time', {:current_time => Time.zone.now.utc}] #Can't perform named_scope here, so this isn't dry
  
  
  # This gives admin rights to the first sign-up.
  # Just remove it if you don't want that
  # before_create { |user| user.administrator = true if !Rails.env.test? && count == 0 }

  has_many :user_profiles,  :foreign_key => "owner_id", :dependent=>:destroy
  has_many :boats, :foreign_key=>"owner_id",  :dependent=>:destroy

  has_many :joined_crew_memberships, :class_name=>"CrewMembership", :foreign_key=>"invitee_id",  :dependent=>:destroy #TODO Better rename the class as
  has_many :joined_crews, :through=>:joined_crew_memberships
  
  has_many :crews, :foreign_key=>"owner_id",  :dependent=>:destroy #because crew belongs_to user
  [:enrollments, :registrations].each {|v|
    has_many v, :foreign_key=>"owner_id", :dependent=>:destroy
  }
  has_many :crew_memberships, :through => :crews, :foreign_key=>"owner_id", :dependent => :destroy
  
  
  

  # Create a new crew
  
  def update_crews_insert_person_crew
    ActiveRecord::Base.transaction do
      unless Crew.first :conditions => {:owner_id => id, :crew_type => Crew::Type::PERSON}
        Crew.create :name => "One Person Crew",
                    :gender => gender,
                    :crew_type => Crew::Type::PERSON,
                    :owner => self
      end
    end
  end
  
  def skipper_crew
    update_crews_insert_person_crew
    Crew.first :conditions => {:crew_type => Crew::Type::PERSON, :owner_id => self.id}
  end
  
  def crews_with_skipper_only
    skipper_crew
    crews_without_skipper_only
  end

  alias_method_chain :crews, :skipper_only
  
  # --- Signup lifecycle --- #

  lifecycle do

    # STATES ARE TO BE INTERPRETED AS FOLLOWS:
    # active: the user's account is accessible
    # inactive: the user's account is not accessible - state change performed by administrator
    # invited: an invited user's state - stage set by an existing user via an invitation

    state :active
    state :inactive, :default => true 
    state :invited
    state :signed_up

    create :invite, :new_key => true, :params => [:email_address],
           :available_to => "User",
           :become => :invited do

      UserMailer.deliver_invite_user acting_user, 
                                     email_address,
                                     lifecycle.key
    end

    transition :accept_invitation, { :invited => :active }, :available_to => :key_holder,
               :params => [:password, :password_confirmation]

    create :signup, :new_key => true, :available_to => "Guest",
           :params => [:email_address], :become => :signed_up do
      
      UserMailer.deliver_signup_activation email_address, lifecycle.key
      
    end

    transition :activate_signup, {:signed_up => :active}, :available_to => :key_holder,
               :params => [:password, :password_confirmation]
    
    transition :inactivate_account, {:active => :inactive}, 
               :available_to => :admins

    transition :activate_account, {:inactive => :active}, 
               :available_to => :admins

    transition :request_password_reset, { :active => :active }, :new_key => true do
      UserMailer.deliver_forgot_password(self, lifecycle.key)
    end

    transition :reset_password, { :active => :active }, :available_to => :key_holder,
               :params => [ :password, :password_confirmation ]
  end

  def user_profile
    user_profiles.first
  end

  def user_profile=(user_profile)
    user_profile = [user_profile]
  end

  def gender
    return user_profile.gender if user_profile
    return :Open
  end
  # --- Permissions --- #

  def create_permitted?
    false
  end

  def update_permitted?
    return false if (acting_user != self && !acting_user.administrator?) || !self.active?
    return true if only_changed? :crypted_password, :current_password, :password, :password_confirmation
  end

  def destroy_permitted?
    acting_user.administrator?
  end

  def view_permitted?(field)
    return false if field == :state && !acting_user.administrator?
    true
  end

  # Security
  def is_owner_of? an_object
    return true if self.administrator? 
    if an_object.respond_to? :organization
      return true if self.organization_admin? an_object.organization
    end
    an_object.owner_is?(self) if an_object.respond_to? :owner_is?
  end

  def organization_admin?(organization)
    return true if self.administrator? 
    return false if organization.nil?
    raise "Organization expected. Got #{organization.class}" unless organization.kind_of? Organization
    return true if self.organizations_as_admin.find_by_id( organization.id )
    return false
  end

  def any_organization_admin?
    return true if self.administrator? 
    self.organizations_as_admin.count > 0
  end

  def active?
    #Those might be more than one state like flagged users.
    self.state == "active"
  end
  
  def label
    if user_profile and !user_profile.name.blank?
      user_profile.name
    else
      to_s
    end
  end
  
  private

    #GP: find a better way
    def admins
      User.find(:all, :conditions => {:administrator => true})
    end

    def already_signedup_check

      return unless email_address

      u = User.find_by_email_address(email_address)
      if u && u.state == 'signed_up'
        u.destroy
      end
    end

end
