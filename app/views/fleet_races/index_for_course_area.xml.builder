xml.instruct!
xml.fleet_races("type"=>"array") do
  @this.each do | entity |
    xml.fleet_race do
      xml.id entity.id
      xml.number entity.number
      xml.color entity.color
    end
  end
end
