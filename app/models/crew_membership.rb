class CrewMembership < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    timestamps
  end

  attr_accessor :invitee_email, :type => :email_address

  before_create :initialize_invitee
  after_create :update_crew_gender
  after_destroy :update_crew_gender

  belongs_to :joined_crew, :class_name => "Crew"
  delegate :owner, :to => :joined_crew
  belongs_to :invitee, :class_name => "User"

  validates_format_of :invitee_email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, 
      :unless => Proc.new { |cm| cm.invitee }
      
  validates_each :invitee_email do |model, attr, value|
    model.errors.add(:invitee_email, "already invited") unless model.invitee_does_not_exist?
  end
  
  validates_each :joined_crew do |model, attr, value|
    model.errors.add(:joined_crew, "can't be of type person") if value and value.crew_type == Crew::Type::PERSON
  end
  
  validates_presence_of :joined_crew
  validates_presence_of :invitee, :if => Proc.new { |cm| cm.invitee_email.blank? }
  
  named_scope :with_owner, lambda { |owner| { :conditions => { :owner => owner } } }
  named_scope :with_invitee, lambda { |invitee| { :conditions => { :invitee => invitee } } }
  named_scope :accepted_invitations_for_crew, lambda { |crew| 
                                                     {:conditions => { :joined_crew_id => crew, :state => 'accepted'} } }

  lifecycle do

    state :invited, :accepted, :ignored, :retracted

    create :invite, :new_key => true, :params => [:joined_crew, :invitee_email], 
           :become => :invited, :available_to => "User" do

      UserMailer.deliver_crew_membership_invitation self, self.lifecycle.key

    end

    # for the invitee
    transition :accept, { :invited => :accepted }, :available_to => :access_conditions do
      UserMailer.deliver_crew_membership_accepted self
    end

    # for the invitee
    transition :ignore, { :invited => :ignored }, :available_to => :access_conditions do
      UserMailer.deliver_crew_membership_ignored self
    end

    # for the invitor
    transition :retract, { :invited => :retracted }, :available_to => :owner do
      self.destroy
#       UserMailer.deliver_crew_membership_retracted
    end

    # for the invitor
    transition :retract, { :accepted => :retracted }, :available_to => :owner do
      self.destroy
#       UserMailer.deliver_crew_membership_retracted
    end

  end

  def invitee_does_not_exist?
    return false if owner and owner.email_address == invitee_email
    return false if joined_crew and joined_crew.crew_memberships.*.invitee.map(&:email_address).include?(invitee_email)
    true
  end

  def access_conditions
    if lifecycle.valid_key?
      acting_user if acting_user.is_a?(Guest) || acting_user == invitee
    else
      invitee
    end
  end

  def initialize_invitee

    return nil unless invitee_email
    return nil if invitee_email.empty? || invitee_email.blank?

    u = User.find_by_email_address(invitee_email)

    unless u
      u = User::Lifecycle.invite(owner, :email_address => invitee_email)
    end

    self.invitee = u
  end

  def update_crew_gender
    joined_crew.update_crew_gender
  end

  # --- Permissions --- #

  def create_permitted?
    false #Force life cycle create transition
  end

  def update_permitted?
    false
  end

  def destroy_permitted?
    joined_crew.destroyable_by?(acting_user)
  end

  def view_permitted?(field)
    joined_crew.viewable_by?(acting_user)
  end

end
