class CrewHints < Hobo::ViewHints
  parent :owner
  # model_name "My Model"
  # field_names :field1 => "First Field", :field2 => "Second Field"
  # field_help :field1 => "Enter what you want in this field"
  # children :primary_collection1, :aside_collection1, :aside_collection2

  # children :crew_memberships, done dynamically in the taglib based on Crew::Type
  
end
