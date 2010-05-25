class User < ActiveRecord::Base

  hobo_user_model # Don't put anything above this
  has_etag

  fields do
    email_address :email_address, :login => true , :name=>true
    administrator :boolean, :default => false
    timestamps
  end
  
  has_many :organization_admin_roles, :dependent=>:destroy
  has_many :organizations_as_admin, :through=>:organization_admin_roles, :source=>:organization

  # This gives admin rights to the first sign-up.
  # Just remove it if you don't want that
#   before_create { |user| user.administrator = true if !Rails.env.test? && count == 0 }

  #TODO :active default false, activates by email


  def person
    people.first
  end

 

  # --- Signup lifecycle --- #

  lifecycle do

    state :active, :default => true

    create :signup, :available_to => "Guest",
           :params => [:email_address, :password, :password_confirmation],
           :become => :active

    transition :request_password_reset, { :active => :active }, :new_key => true do
      UserMailer.deliver_forgot_password(self, lifecycle.key)
    end

    transition :reset_password, { :active => :active }, :available_to => :key_holder,
               :params => [ :password, :password_confirmation ]

  end


  has_many :people #FIXME has_one optional :people

  # --- Permissions --- #

  def create_permitted?
    false
  end

  def update_permitted?
    acting_user.administrator? ||
      (acting_user == self && only_changed?(:email_address, :crypted_password,
                                            :current_password, :password, :password_confirmation))
    # Note: crypted_password has attr_protected so although it is permitted to change, it cannot be changed
    # directly from a form submission.
  end

  def destroy_permitted?
    acting_user.administrator?
  end

  def view_permitted?(field)
    true
  end
  
  # Security
  def organization_admin?(organization)
#     return true
    return true if self.administrator? 
    raise "organization expected" unless organization.kind_of? Organization
    return true if self.organizations_as_admin.find_by_id( organization.id )
    return false
  end

  def any_organization_admin?
    return true if self.administrator? 
    self.organizations_as_admin.count > 0
  end
  

end
