class EventSeries < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name :string, :required, :unique, :null=>false, :index=>true
    description :text, :primary_content=>true
    timestamps
  end
  belongs_to :organization, :null=>false
  has_many :events

  validates_presence_of :organization

  # --- Permissions --- #

  def create_permitted?
    acting_user.organization_admin?( self.organization )
  end

  def update_permitted?
    acting_user.organization_admin?( self.organization )
  end

  def destroy_permitted?
    acting_user.organization_admin?( self.organization )
  end

  def view_permitted?(field)
    true
  end

end
