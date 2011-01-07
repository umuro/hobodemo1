class FleetRacesController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => :index
  auto_actions_for :race, [:index, :new, :create]
  auto_actions_for :course_area, [:index] #mobile


  show_action :flags do #mobile 
    hobo_show
    @flags = @this.flags
  end

  show_action :boats do #mobile #TODO should be Boat.index_for_fleet_race
    hobo_show
    @boats = @this.boats
  end
  
end
