xml.instruct!
xml.events("type"=>"array") do
  for event in @this.events_as_spotter do
    xml.event do
      xml.id event.id
      xml.name event.name
    end
  end
end