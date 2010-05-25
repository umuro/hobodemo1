class Person < ActiveRecord::Base

  hobo_model # Don't put anything above this

   Gender = HoboFields::EnumString.for(:Male, :Female)

  fields do
    first_name   :string
    middle_name  :string
    last_name    :string, :name=>true
    gender       Person::Gender, :required
    if_person_id :string
    birthdate    :date
    timestamps
  end

  belongs_to :user
  belongs_to :country
  has_many :crew_members
  has_many :team_partipications, :through=>:crew_members

  validates_presence_of :country
  validates_presence_of :user_id
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
