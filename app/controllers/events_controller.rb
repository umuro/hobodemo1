class EventsController < ApplicationController
  @umur = 'somewhere'
  hobo_model_controller

  auto_actions_for :event_folder, [:index, :new, :create]
  auto_actions :all, :except => :index
#   auto_actions :read_only, :except => :index
  
  index_action :active do
    hobo_index Event.active
  end
    
  show_action :todays_active_fleet_races do
    hobo_show
    @todays_active_fleet_races = @this.fleet_races.today_for(@this).active
  end
end
