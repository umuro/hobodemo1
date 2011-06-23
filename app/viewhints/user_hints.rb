class UserHints < Hobo::ViewHints

  # model_name "My Model"
  # field_names :field1 => "First Field", :field2 => "Second Field"
  # field_help :field1 => "Enter what you want in this field"
  # children :primary_collection1, :aside_collection1, :aside_collection2

  field_names :password => "Choose a password", 
              :password_confirmation => "Re-enter password"

  children :enrollments, :enrollments, :boats, :crews, :joined_crews, :events_as_spotter
end