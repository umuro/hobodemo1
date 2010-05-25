xml.instruct!
xml.events("type"=>"array") do
  @this.each do | event |
    xml.event do
      xml.id event.id
      xml.name event.name
    end
  end
end