class CrewMember < ActiveRecord::Base

  hobo_model # Don't put anything above this

  Position =  HoboFields::EnumString.for(:S, :C)
  fields do
    position CrewMember::Position, :required, :null=>false
    remarks      :text, :primary_content=>true
    timestamps
  end

  belongs_to :team_participation
  belongs_to :person

  validates_presence_of :team_participation
  validates_presence_of :person
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
