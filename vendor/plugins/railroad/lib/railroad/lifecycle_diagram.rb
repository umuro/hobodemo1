# RailRoad - RoR diagrams generator
# http://railroad.rubyforge.org
#
# Copyright 2007-2008 - Javier Smaldone (http://www.smaldone.com.ar)
# See COPYING for more details

# Hobo::Lifecycle code provided by Bryan Larsen (http://bryan.larsen.st)

# Diagram for Hobo Lifecycle
class LifecycleDiagram < AppDiagram

  def initialize(options)
    #options.exclude.map! {|e| e = "app/models/" + e}
    super options 
    @graph.diagram_type = 'Lifecycle'
    # Processed habtm associations
    @habtm = []
  end

  # Process model files
  def generate
    STDERR.print "Generating Lifecycle diagram\n" if @options.verbose
    files = Dir.glob("app/models/*.rb") 
    files += Dir.glob("vendor/plugins/**/app/models/*.rb") if @options.plugins_models
    files -= @options.exclude
    files.each do |f| 
      process_class extract_class_name('app/models/', f).constantize
    end
  end
  
private
  
  # Load model classes
  def load_classes
    begin
      disable_stdout
      files = Dir.glob("app/models/**/*.rb")
      files += Dir.glob("vendor/plugins/**/app/models/*.rb") if @options.plugins_models
      files -= @options.exclude                  
      files.each {|file| get_model_class(file) }
      enable_stdout
    rescue LoadError
      enable_stdout
      print_error "model classes"
      raise
    end
  end  # load_classes

  # This method is taken from the annotate models gem
  # http://github.com/ctran/annotate_models/tree/master
  #
  # Retrieve the classes belonging to the model names we're asked to process
  # Check for namespaced models in subdirectories as well as models
  # in subdirectories without namespacing.
  def get_model_class(file)
    model = file.sub(/^.*app\/models\//, '').sub(/\.rb$/, '').camelize
    parts = model.split('::')
    begin
      parts.inject(Object) {|klass, part| klass.const_get(part) }
    rescue LoadError
      Object.const_get(parts.last)
    end
  end

  # Process a model class
  def process_class(current_class)
    
    STDERR.print "\tProcessing #{current_class}\n" if @options.verbose

    states = nil

    return if !defined?(current_class::Lifecycle)
    return if current_class::Lifecycle.states.empty?

    node_attribs = []
    node_type = 'aasm'

    current_class::Lifecycle.states.each do |state_name, state|
      node_shape = (current_class::Lifecycle.default_state === state) ? ", peripheries = 2" : ""
      node_attribs << "#{current_class.name.downcase}_#{state_name} [label=#{state_name} #{node_shape}];"
    end
    @graph.add_node [node_type, current_class.name, node_attribs]
    
    current_class::Lifecycle.transitions.each do |transition|
      transition.start_states.each do |start_state|
        @graph.add_edge [
          'event', 
          current_class.name.downcase + "_" + start_state.to_s, 
          current_class.name.downcase + "_" + transition.end_state.to_s, 
          transition.name.to_s
                      ]
      end
    end
  end # process_class
end # class LifecycleDiagram
