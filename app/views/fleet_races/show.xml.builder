xml.instruct!
xml.fleet_race do
  xml.id @this.id
  xml.event_id @this.event_id
  xml.race_id @this.race_id
  xml.number @this.number #Race Number
  xml.color @this.color #Fleet Color
  xml.course_id @this.course_id
  xml.course_area_id @this.course_area_id
end
