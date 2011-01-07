xml.instruct!
xml.data {
  xml.key @rsx_mobile_service.api_key
  event = @rsx_mobile_service.event
  xml.tag! 'start-time', event.start_time.iso8601
  xml.tag! 'end-time', event.end_time.iso8601
  xml.description event.description
  xml.place event.place
  for race in event.races
    xml.race(:id => race.id) {
      g = race.gender
      unless g.eql? "O" or g.eql? "Open"
        xml.male if %w(M Men Man Male).includes? g
        xml.female if %w(F Female W Women Woman).includes? g
      end
      for fr in race.fleet_races
        xml.tag!('fleet-race', :id => fr.id) {
          xml.color fr.color
          xml.tag! 'scheduled-time', fr.scheduled_time.iso8601
          
          for boat in fr.boats
            xml.boat(:name => boat.sail_number, :'sail-number' => boat.sail_number, :id => boat.id)
          end
        }
      end
    }
  end
}
