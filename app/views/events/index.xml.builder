xml.instruct!
xml.events do
  @this.each do | event |
    xml.event do
      xml.id
      xml.name event.name
    end
  end
end