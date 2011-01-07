class UserProfile < ActiveRecord::Base

  hobo_model # Don't put anything above this

  Gender = HoboFields::EnumString.for(:Male, :Female)

  fields do
    first_name   :string
    middle_name  :string
    last_name    :string, :required
    gender       UserProfile::Gender, :required
    if_person_id :string # if = International Federation
    birthdate    ExtendedDate,
                 :start_year => (lambda { |date| DateTime.now.year - 120 }),
                 :end_year => (lambda { |date| DateTime.now.year })
    twitter      UrlHyperlink
    facebook     UrlHyperlink
    homepage     UrlHyperlink
    mobile_phone :string
    timestamps
  end

  belongs_to :owner, :class_name => "User", :creator => true
  belongs_to :country

  def name
    extra = "#{first_name} #{middle_name}".strip
    unless extra.empty?
      "#{last_name}, #{extra}"
    else
      "#{last_name}"
    end
  end

  validates_presence_of :country
  validates_presence_of :owner

  after_save :update_crew_gender
  
  def update_crew_gender
    owner.joined_crew_memberships.*.update_crew_gender
    owner.crews.*.update_crew_gender
  end

  # --- Permissions --- #

  def create_permitted?
    acting_user.is_owner_of? self
  end

  def update_permitted?
    acting_user.is_owner_of? self
  end

  def destroy_permitted?
    acting_user.is_owner_of? self
  end

  def view_permitted?(field)
    a = acting_user
    return false if a.is_a? ::Guest
    return false if field == :mobile_phone && !(a.is_owner_of?(self) || a.administrator? || a.any_organization_admin?)
    true
  end

end
