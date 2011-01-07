class Crew < ActiveRecord::Base

  hobo_model # Don't put anything above this

  Type = HoboFields::EnumString.for(:Person, :Group)
  
  fields do
    name :string, :required, :null=>false, :index=>true 
    gender Race::Gender, :required, :default=>Race::Gender::OPEN
    crew_type Type, :default => Type::GROUP
    timestamps
  end

  belongs_to :owner, :class_name => "User", :creator => true
  has_many :crew_memberships, :foreign_key => "joined_crew_id", :dependent => :destroy

  validates_uniqueness_of :name, :scope => [:owner_id, :crew_type]  #TODO card has owner because it's scoped to the owner
  has_many :enrollments
  
  never_show :crew_type

  def skipper
    owner #unless self[:skipper]
  end
  
  def label
    if crew_type == Type::PERSON
      skipper.label
    elsif skipper.label.is_a? HoboFields::EmailAddress
      "#{skipper.label.to_html} - #{name}"
    else
      "#{skipper.label} - #{name}"
    end
  end
  
  def update_crew_gender
    accepted_crew_memberships = CrewMembership.accepted_invitations_for_crew(self)
    genders = accepted_crew_memberships.*.invitee.*.gender
    
    genders << skipper.gender

    gender = Race::Gender::MALE
    gender = Race::Gender::FEMALE if genders.include?(Race::Gender::FEMALE)
    gender = Race::Gender::OPEN if (genders.include?(Race::Gender::MALE) && 
                                    genders.include?(Race::Gender::FEMALE))
    save
  end

  # --- Permissions --- #

  def create_permitted?
    return false if any_changed? :gender
    acting_user.is_owner_of? self
  end

  def update_permitted?
    return false if crew_type == Type::PERSON
    return true if acting_user.administrator?
    return false if enrollments.size
    return false if any_changed? :gender
    acting_user.is_owner_of? self
  end

  def destroy_permitted?
    return true if acting_user.administrator?
    return false if enrollments.size > 0
    acting_user.is_owner_of? self
  end

  def view_permitted?(field)
    true
  end

end
