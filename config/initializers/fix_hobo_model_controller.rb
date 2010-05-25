#config/initializers/fix_hobo_model_controller.rb

module FixHoboModelController
    #lib/hobo/model_controller.rb
    def hobo_create(*args, &b)
      options = args.extract_options!
      attributes = options[:attributes] || attribute_parameters || {}
      if self.this ||= args.first
        this.user_update_attributes(current_user, attributes)
      else
        self.this = new_for_create(attributes)
#         this.save  #Original Line
    this.with_acting_user(current_user) {this.save} #SUGGESTED FIX
      end
      create_response(:new, options, &b)
    end
end

module ActionController
  class Base
    def self.hobo_model_controller(model=nil)
      @model = model
      include Hobo::ModelController
      include FixHoboModelController
    end
  end
end
