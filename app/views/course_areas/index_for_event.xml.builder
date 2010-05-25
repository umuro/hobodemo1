xml.instruct!
xml.course_areas("type"=>"array") do
  @this.each do | entity |
    xml.course_area do
      xml.id entity.id
      xml.name entity.name
    end
  end
end