require 'factory_girl'

class CountryFactoryHelper
  include Singleton
  
  def perform n
    @doc ||= Nokogiri::XML.parse Net::HTTP.get "comtrade.un.org", "/ws/refs/getCountryList.aspx"

    seq = n
    ActiveRecord::Base.transaction do
      @doc.xpath("/Country/r").each { |r| 
        n -= 1
        if n == 0
          name = HTMLEntities.new.decode r.xpath("name/text()")
          code = HTMLEntities.new.decode r.xpath("iso3/text()")
          code = name if code == nil || code.empty?
          return [name, code] unless Country.find_by_code code
          n=1
        end
      }
      return ["Country#{seq}","C#{seq}"]
    end    
  end
end  

Factory.define :country do |f|
  f.sequence(:name) {|n| CountryFactoryHelper.instance.perform(n).first}
  f.sequence(:code) {|n| CountryFactoryHelper.instance.perform(n).last}
end
