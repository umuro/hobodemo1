class TeamParticipation < ActiveRecord::Base
  #PAUL Team and/or boat participates?

  hobo_model # Don't put anything above this

  fields do
    date_entered    :date
    date_measured   :date
    measured_passed? :boolean, :default=>false
    insured?         :boolean, :default=>false
    paid?            :boolean, :default=>false
    #FIXME status lifecycle
    timestamps

    #Team Fields
    description :string, :primary_content=>true #PAUL name->description team_rid->name
    team_rid :string, :required, :unique, :name=>true
    gender   Race::Gender, :required
  end

  index [:boat_id, :event_id], :unique=>true
  
  belongs_to :event
  belongs_to :boat

  belongs_to :country
  has_many :crew_members
  has_many :people, :through=>:crew_members

  validates_presence_of :event
  validates_presence_of :boat

  validates_uniqueness_of :boat_id, :scope=>:event_id
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
