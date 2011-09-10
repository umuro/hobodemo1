class Enrollment < ActiveRecord::Base

  hobo_model # Don't put anything above this
  abstract_registration_model
  
  fields do
    date_measured   ExtendedDate
    measured        :boolean, :default=>false
    insured         :boolean, :default=>false
    paid            :boolean, :default=>false
    timestamps
  end
  include EventLocalTime

  index [:boat_id, :registration_role_id], :unique=>true

  belongs_to :boat
  belongs_to :crew

  has_many :enrollment_wizards, :dependent=>:destroy

  #By default is set to the skipper's nationality. 
  #But one can enroll to represent France although being Chinese
  belongs_to :country

  validates_presence_of :boat
  validates_presence_of :crew
  validates_presence_of :country

  validates_uniqueness_of :boat_id, :scope=>:registration_role_id

  delegate :skipper, :to=>:crew
  delegate :gender, :to=>:crew
  delegate :sail_number, :to=>:boat
  delegate :boat_class, :to=>:boat

  #FIXME. member needs to be db field
  alias :member :skipper #Member is who is registered in an Event
  
  def name
    "#{skipper} with #{sail_number}"
  end

  # --- Lifecycle --- #

  lifecycle do
    create :enroll, :params => [:registration_role, :boat, :crew, :country],
           :become => :requested, :available_to => "User", :user_becomes => :owner
    #re-enroll since the record is already created
    transition :re_enroll, {:rejected => :requested}, :available_to=>:owner
    transition :re_enroll, {:retracted => :requested}, :available_to=>:owner

    transition :re_enroll, {:retracted => :destroy}, :available_to=>User
    transition :re_enroll, {:rejected => :destroy}, :available_to=>User
  end

  # --- Permissions --- #

  def any_additional_changed?
    any_changed? :gender, :paid, :insured, :measured
  end

end
