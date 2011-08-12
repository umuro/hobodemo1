class TimeZoneRichType < String
  COLUMN_TYPE = :string
  HoboFields.register_type(:time_zone, self)

#    def format
#     self.strip if self
#    end

   def to_html(xmldoctype = true)
    self.to_tz.to_s
   end

  def is_number?
    self =~ /^ *[+-]*[0-9]+ *$/
  end

  def to_tzindex
    return self.to_i if self.is_number?
    return self
  end

  def to_tz
    ActiveSupport::TimeZone[self.to_tzindex]
  end

end
