xml.instruct!
xml.course do
  xml.id @this.id
  xml.name @this.name
  xml.spots("type"=>"array") do
    @this.spots.each do | entity |
      xml.spot do
        xml.id entity.id
        xml.name entity.name
        xml.spot_type entity.spot_type
        xml.position entity.position
      end
    end
  end

end