class FleetMembership < ActiveRecord::Base
  hobo_model # Don't put anything above this

  fields do
  end

  belongs_to :fleet
  belongs_to :boat
end
