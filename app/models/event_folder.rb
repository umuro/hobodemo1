class EventFolder < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name :string, :required, :null=>false, :index=>true
    description :text, :primary_content=>true
    timestamps
  end
  set_default_order "updated_at DESC"
  
  belongs_to :organization, :null=>false
  validates_presence_of :organization
  validates_uniqueness_of :name, :scope=>:organization_id #TODO EventFolder Card

  has_many :events, 		:dependent=>:destroy

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
