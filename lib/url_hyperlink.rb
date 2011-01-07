# UrlHyperlink is based on string and mimics URL display with a link
class UrlHyperlink < String
  
  def format
    return nil if self.empty?
    return self if validate
    self[0..-1] = "http://#{self}" unless self =~ /^http[s]?:\/\//
  end
  
  def validate
    validate_with self
  end
  
  def to_html(xmldoctype = true)
    b = Nokogiri::HTML::Builder.new do |html|
      html.a self, :href => self
    end
    b.doc.root.to_html
  end
  
  private
  
  def validate_with v
    begin 
      url = URI.parse self
      raise "#{url.scheme} not accepted as valid URL scheme" unless url.scheme == "http" || url.scheme == "https" || url.scheme == nil
    rescue Exception => e
      return e.message
    end
    nil
  end
  
  # Register this to use the "string" column type in the database
  COLUMN_TYPE = :string
  HoboFields.register_type(:url_hyperlink, self)
  
end
