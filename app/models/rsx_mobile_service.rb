class RsxMobileService < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    api_key :string
    timestamps
  end
  
  belongs_to :event
  validates_presence_of :event
  validates_presence_of :api_key
  delegate :organization, :to => :event
  
  lifecycle do
    
    state :accept_position_update
    
    create :ready, :become => :accept_position_update, :available_to => :all
    
    transition :position_update, {:accept_position_update => :accept_position_update}
    
  end
  
  before_validation :init_params
  after_save        RsxMobileServiceJobs::Touched.new
  
  attr_reader :shadow_mode
  
  def initialize *args; @shadow_mode = false; super *args; end
  
  # --- Permissions --- #

  def create_permitted?
    false
  end

  def update_permitted?
    false
  end

  def destroy_permitted?
    acting_user.organization_admin? self
  end

  def view_permitted?(field)
    true
  end
  
  # Updates the object's api key, yielding and saving
  
  def shadow_update
    generate_api_key
    r = yield
    @shadow_mode = true
    save
    @shadow_mode = false
    r
  end

  private
  

  def init_params
    if new_record?
      generate_api_key
      unless User.find(:first, :conditions => {:email_address => "rsx_mobile_service@local.loc"})
        User.create!(:email_address => "rsx_mobile_service@local.loc", :state => "inactive", :administrator => false).save
      end
    end
    # Return true to make before_validation happy
    true
  end
  
  def generate_api_key
    self.api_key = Digest::SHA1.hexdigest("#{object_id}-#{state}-#{DateTime.now.to_i}")
  end
  
end
