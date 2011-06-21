module AbstractRegistration
  def self.become c
    c.class_eval do
#      belongs_to :event
      # Validate registration role and enrollment role (enrollment role before save, registration role after save)
	belongs_to :registration_role, :null => false
#       if self != Enrollment
# 	belongs_to :registration_role, :null => false
#       else
# 	belongs_to :registration_role, :conditions => "operation = \"#{self.name}\"", :null => false
# 	Fails in PostGres:
# 	SELECT * FROM "registration_roles" WHERE ("registration_roles"."id" = 1 AND ((operation = "Enrollment"))) ):
#       end
      belongs_to :owner, :class_name => "User", :creator => true
      
      validates_presence_of :owner
#      validates_presence_of :event
      validates_presence_of :registration_role_id

      delegate :event, :to=>:registration_role
      delegate :organization,  :to=>:event
      delegate :organization_admins, :to=>:organization

      attr_accessor :admin_comment, :type => :text

      named_scope :visible, lambda {|owner_id|
        { :conditions =>["state = 'accepted' or owner_id = ? ", owner_id] }
      }

      lifecycle do
	state :requested
	state :accepted
	state :rejected
	state :retracted
    
	transition :retract, {:requested => :retracted}, :available_to => :owner
	transition :accept, {:requested => :accepted}, :available_to => :organization_admins do
	  UserMailer.deliver_event_abstract_registration_accepted(self)
	end
	transition :reject, {:requested => :rejected}, :params=>[:admin_comment], :available_to => :organization_admins do
	  UserMailer.deliver_event_abstract_registration_rejected(self)
	end
      end #lifecycle

      # --- Permissions --- #

      def create_permitted?
	false #Creation delegated to lifecycle actions
      end
      def destroy_permitted?
	acting_user.is_owner_of? self
      end

      def view_permitted?(field)
	true
      end

      def any_additional_changed?
	false
      end
      
      def update_permitted?
	return false if state == 'accepted'
 	return false if !acting_user.organization_admin?(self.organization) &&
 	  any_additional_changed?
 
	acting_user.is_owner_of?(self)
      end

    end
  end
end
