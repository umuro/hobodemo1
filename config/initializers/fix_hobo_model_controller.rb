#config/initializers/fix_hobo_model_controller.rb

module FixHoboModelController

  def hobo_create(*args, &b)
    options = args.extract_options!
    attributes = options[:attributes] || attribute_parameters || {}
    if self.this ||= args.first
      this.user_update_attributes(current_user, attributes)
    else
      self.this = new_for_create(attributes)
      # this.save  #Original Line
      this.with_acting_user(current_user) {this.save} #SUGGESTED FIX
    end
    create_response(:new, options, &b)
  end

  def creator_page_action(name, options={}, &b)
    self.this ||= model.user_new current_user, attribute_parameters #by Umur
    this.exempt_from_edit_checks = true
    #FIXME creator totally ignores this
    @creator = model::Lifecycle.creator(name)
    raise Hobo::PermissionDeniedError unless @creator.allowed?(current_user)
    response_block &b
  end

  def hobo_create_for(owner_association, *args, &b)
    options = args.extract_options!
    owner, association = find_owner_and_association(owner_association)
    attributes = options[:attributes] || attribute_parameters || {}
    if self.this ||= args.first
      this.user_update_attributes(current_user, attributes)
    else
      self.this = association.new(attributes)
      this.with_acting_user(current_user) do #by Giorgio 
        this.save
      end
    end
    create_response(:"new_for_#{name_of_auto_action_for(owner_association)}", options, &b)    
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