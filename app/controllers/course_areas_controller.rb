class CourseAreasController < ApplicationController

  hobo_model_controller

  #auto_actions :all
  auto_actions :read_only
  auto_actions_for :event, [:index, :new, :create]

  show_action :todays_active_races do
    hobo_show
    @todays_active_races = @this.races.today.active
  end

end
