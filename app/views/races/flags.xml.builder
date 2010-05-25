xml.instruct!
xml.flags("type"=>"array") do
  @flags.each do | flag |
    xml.flag do
      xml.id flag.id
      xml.name flag.name
    end
  end
end