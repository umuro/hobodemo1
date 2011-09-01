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

      named_scope :admin, :conditions=>[" state <> 'rejected' "]

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
	transition :cancel, {:accepted => :requested}, :available_to => :organization_admins
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
	return false if state == 'accepted' && !acting_user.organization_admin?(self.organization)
 	return false if !acting_user.organization_admin?(self.organization) &&
 	  any_additional_changed?
 
	acting_user.is_owner_of?(self)
      end

      def self.csv_sort(a,b)
        result = a.state <=> b.state
        return result || 1 unless result == 0
	sort(a,b)
      end
      def self.list_sort(a,b)
	sort(a,b)
      end
      #TEST
      def self.sort(a,b)
# puts "#{a.id} <=> #{b.id}"	
        result = a.registration_role.name <=> b.registration_role.name
        return result || 1 unless result == 0

        result = a.gender.to_s<=> b.gender.to_s
        return result || 1 unless result == 0

        if a.respond_to?(:boat) && a.boat && a.boat.boat_class
          result = a.boat.boat_class.name <=> b.try(:boat).try(:boat_class).try(:name)
          return result || 1 unless result == 0
        end

        if a.member.user_profile.nil?
          return -1
        elsif b.member.user_profile.nil?
          return 1
        else
          result = a.member.user_profile.last_name <=> b.member.user_profile.last_name
          return result || 1
        end
      end
      def <=>(b)
	self.class.sort(self,b)
      end

      delegate :last_name, :to=>:member
      delegate :first_name, :to=>:member
      delegate :email_address, :to=>:member
      def email
	email_address
      end
      def nationality
	country.try(:code)
      end
      
    end
  end
end
