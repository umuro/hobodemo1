class RegistrationRoleHints < Hobo::ViewHints
  parent :event
  # model_name "My Model"
  # field_names :field1 => "First Field", :field2 => "Second Field"
  # field_help :field1 => "Enter what you want in this field"
  # children :primary_collection1, :aside_collection1, :aside_collection2
  field_names :external_markdown => "Notes"
  # The card needs it's own logic for displaying how many registrations/enrollments
  # Therefore, no primary collection is usable
  # children :registrations/:enrollments
end
