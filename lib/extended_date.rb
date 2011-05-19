# ExtendedDate is a simple extension to date making it possible to set a start year and end year inside a Hobo
# application. This is necessary for things such as birthdays and events far in the future or past.
class ExtendedDate < Date
  
  # It is necessary to override new, as the behavior of Hobo likes to give it the base object. This will conflict
  # with the original civil (and aliased new) method.
  def self.new d
    if d.is_a? Date
      self.civil d.year, d.month, d.day, d.sg
    else
      return nil if d.empty? || d.nil?
      begin
        d, _, ex = d.partition('/')
        m, _, y = ex.partition('/')
        self.civil y.to_i, m.to_i, d.to_i
      rescue
        self.civil
      end
    end
  end
  
  def validate
    if self == Date.civil
      "an invalid date has been entered"
    else
      nil
    end
  end
  
  # This is necessary for validation. There is nothing to be really validated though, as the date class will take care
  # of it.
  def length; 20; end
  
  # Register this to use the "date" column type in the database
  COLUMN_TYPE = :date
  HoboFields.register_type(:extended_date, self)
  
end
