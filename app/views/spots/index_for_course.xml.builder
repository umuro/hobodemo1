xml.instruct!
xml.spots("type"=>"array") do
  @this.each do |entity|
    xml.spot do
      xml.position entity.position
      xml.spot_type entity.spot_type
    end
  end
end