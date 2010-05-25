xml.instruct!
xml.boats("type"=>"array") do
  @boats.each do | boat |
    xml.boat do
      xml.id boat.id
      xml.name boat.name
    end
  end
end