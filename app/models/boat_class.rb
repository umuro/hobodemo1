class BoatClass < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name               :string, :required, :unique, :null=>false
    description        :text, :primary_content=>true
    no_of_crew_members :integer, :required, :null=>false
    timestamps
  end

  has_many :boats
  has_many :equipment_types

  belongs_to :organization #boat_classes owned by organization
  
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
    true
  end

end