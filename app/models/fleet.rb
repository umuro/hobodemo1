class Fleet < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    color :string  #PAUL Fleet versus Division
    timestamps
  end

  belongs_to :race
  has_many :fleet_memberships
  has_many :boats, :through=>:fleet_memberships

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
