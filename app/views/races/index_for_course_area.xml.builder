xml.instruct!
xml.races("type"=>"array") do
  @this.each do | entity |
    xml.race do
      xml.id entity.id
      xml.name entity.name
    end
  end
end