module Hobo::Model
  module ClassMethods

    def reverse_reflection(association_name)

      refl = reflections[association_name.to_sym] or raise "No reverse reflection for #{name}.#{association_name}"

      #return nil if refl.options[:conditions] || refl.options[:polymorphic] #by Giorgio

      if refl.macro == :has_many && (self_to_join = refl.through_reflection)
        # Find the reverse of a has_many :through (another has_many :through)
        
        join_to_self  = reverse_reflection(self_to_join.name)
        join_to_other = refl.source_reflection
        other_to_join = self_to_join.klass.reverse_reflection(join_to_other.name)
        
        return nil if self_to_join.options[:conditions] || join_to_other.options[:conditions]
        
        refl.klass.reflections.values.find do |r|
          r.macro == :has_many &&
            !r.options[:conditions] &&
            !r.options[:scope] &&
            r.through_reflection == other_to_join && 
            r.source_reflection  == join_to_self
        end
      else
        # Find the :belongs_to that corresponds to a :has_one / :has_many or vice versa

        reverse_macros = case refl.macro
                          when :has_many, :has_one
                            [:belongs_to]
                          when :belongs_to
                            [:has_many, :has_one]
                          end
	  refl.klass.reflections.values.find do |r|
	    begin
	    r.macro.in?(reverse_macros) &&
	      r.klass >= self &&
	      !r.options[:conditions] &&
	      !r.options[:scope] &&
	      r.primary_key_name == refl.primary_key_name
	    rescue Exception=>e
	      #Otherwise it's not possible to find the problem
	      raise "#{e} reflection problem: #{r.active_record.name} #{r.macro} #{r.name}"
	    end
	  end
      end
    end #reverse_reflection
  end #ClassMethods
end #Hobo::Model