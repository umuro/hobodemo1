class RegistrationRole < ActiveRecord::Base

  hobo_model # Don't put anything above this
  OperationType = HoboFields::EnumString.for( :Default, :Enrollment )

  fields do
    name	:string, :required, :null=>false, :index=>true
    operation	RegistrationRole::OperationType, :required, :null=>false
    external_markdown HoboFields::MarkdownString
    timestamps
  end
  
  attr_readonly :operation

  belongs_to :event
  has_many :enrollments, 		:dependent=>:destroy
  has_many :registrations, 		:dependent=>:destroy

  validates_uniqueness_of :name, :scope=>:event_id

  delegate :organization, :to=>:event
  
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
