require 'factory_girl'
class Mill
  class << self
    def produced? factory_name, ar
      ar && Factory.factory_by_name(factory_name).build_class.find_by_id(ar.id)
    end
    def unless_produced? factory_name, ar
      return ar if produced? factory_name, ar
      if block_given?
	yield
      else
	Factory factory_name
      end
    end
  end
end