class TemplateCourse < Course

  #hobo_model -- Crashes the STI with stack problems (nesting create method aliasing etc.)


  belongs_to :organization
  validates_presence_of :organization
  has_many :spots, :dependent=>:destroy, :foreign_key => 'course_id'
    
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
