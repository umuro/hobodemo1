module AbstractRegistrationExtension

  ActiveRecord::Base.class_eval do
    def self.abstract_registration_model
      AbstractRegistration.become self
    end
  end
  
end