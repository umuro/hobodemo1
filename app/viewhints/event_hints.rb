class EventHints < Hobo::ViewHints
  parent :event_folder
  # model_name "My Model"
  # field_names :field1 => "First Field", :field2 => "Second Field"
  # field_help :field1 => "Enter what you want in this field"
  # children :primary_collection1, :aside_collection1, :aside_collection2

  children :enrollments, :registration_roles, :races, :calendar_entries, :course_areas, :event_spotter_roles
end
