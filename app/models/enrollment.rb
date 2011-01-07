class Enrollment < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    date_measured   :date
    measured        :boolean, :default=>false
    insured         :boolean, :default=>false
    paid            :boolean, :default=>false
    timestamps
  end

  index [:boat_id, :event_id], :unique=>true

  attr_accessor :admin_comment, :type => :text

  belongs_to :owner, :class_name => "User", :creator => true
  #NOTE Dynamic conditions are removed.
  # For example, event becomes nil in the future
  # Instead form drymls has the conditions
  belongs_to :event #, :conditions => ['start_time > ?', Time.now.utc]
  belongs_to :boat #, :conditions => 'owner_id = #{self.owner_id}'
  belongs_to :crew #, :conditions => 'owner_id = #{self.owner_id}'

  #By default is set to the skipper's nationality. 
  #But one can enroll to represent France although being Chinese
  belongs_to :country

#   has_many :fleet_race_memberships
#   has_many :fleet_races, :through=>:fleet_race_memberships

  validates_presence_of :owner
  validates_presence_of :event
  validates_presence_of :boat
  validates_presence_of :crew
  validates_presence_of :country
  
  validates_uniqueness_of :boat_id, :scope=>:event_id

  delegate :skipper, :to=>:crew
  delegate :gender, :to=>:crew
  delegate :sail_number, :to=>:boat
  delegate :organization, :to=>:event

  def name
    "#{skipper} with #{sail_number}"
  end

  # --- Lifecycle --- #

  lifecycle do

    state :requested
    state :accepted
    state :rejected
    state :retracted

    create :enroll, :params => [:event, :boat, :crew, :country], 
           :become => :requested, :available_to => "User", :user_becomes => :owner do
    end

    #re-enroll since the record is already created
    transition :re_enroll, {:rejected => :requested}, :available_to=>:owner do
    end

    transition :re_enroll, {:retracted => :requested}, :available_to=>:owner do
    end

    transition :retract, {:requested => :retracted}, :available_to => :owner do
    end

    transition :accept, {:requested => :accepted}, :available_to => :organization_admins do
      UserMailer.deliver_event_enrollment_accepted(self)
    end

    transition :reject, {:requested => :rejected}, :params=>[:admin_comment], :available_to => :organization_admins do
      UserMailer.deliver_event_enrollment_rejected(self)
    end
  end

  # --- Permissions --- #

  def create_permitted?
    false #Creation delegated to lifecycle actions
  end

  def update_permitted?
    return false if state == 'accepted'
    return false unless (acting_user.organization_admin? self.organization) ||
        none_changed?(:gender, :paid, :insured, :measured)

    acting_user.is_owner_of?(self)
  end

  def destroy_permitted?
    acting_user.is_owner_of? self
  end

  def view_permitted?(field)
    true
  end

  private

    def organization_admins
      organization.organization_admins
    end

end