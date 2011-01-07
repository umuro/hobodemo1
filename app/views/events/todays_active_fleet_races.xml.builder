xml.instruct!
xml.fleet_races("type"=>"array") do
  @todays_active_fleet_races.each do | entity |
    xml.fleet_race do
      xml.id entity.id
      xml.number entity.number
      xml.color entity.color
      # Mobile client needs more details
      xml.course_id entity.course_id
      #xml.course_area_id entity.course_area_id
    end
  end
end
