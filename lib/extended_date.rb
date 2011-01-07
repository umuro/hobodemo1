# ExtendedDate is a simple extension to date making it possible to set a start year and end year inside a Hobo
# application. This is necessary for things such as birthdays and events far in the future or past.
class ExtendedDate < Date
  
  # It is necessary to override new, as the behavior of Hobo likes to give it the base object. This will conflict
  # with the original civil (and aliased new) method.
  def self.new d
    self.civil d.year, d.month, d.day, d.sg
  end
  
  # The meta info is used to build meta information in memory (we can't use files or anything if we are in the cloud)
  class << self
    attr_reader :meta_info
  end
  
  # The declared method is called if available and will initialize the meta information used by the renderer
  def self.declared(model, name, options)
    model_name = "#{model.name.underscore}[#{name}]"
    @meta_info = {} unless @meta_info
    @meta_info[model_name] = {:start_year => options[:start_year], :end_year => options[:end_year]}
  end
  
  # This is necessary for validation. There is nothing to be really validated though, as the date class will take care
  # of it.
  def length; 20; end
  
  # Register this to use the "date" column type in the database
  COLUMN_TYPE = :date
  HoboFields.register_type(:extended_date, self)
  
end
