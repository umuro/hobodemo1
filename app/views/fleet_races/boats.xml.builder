xml.instruct!
xml.boats("type"=>"array") do
  @boats.each do | boat |
    xml.boat do
      xml.id boat.id
      xml.sail_number boat.sail_number
    end
  end
end