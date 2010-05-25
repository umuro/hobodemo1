class RacesController < ApplicationController

  hobo_model_controller

  auto_actions_for :event, [:index, :new, :create]
  auto_actions :all, :except => :index
#   auto_actions :read_only, :except => :index
  auto_actions_for :course_area, [:index]

  show_action :flags do
    hobo_show
    @flags = @this.flags
  end

  show_action :boats do
    hobo_show
    @boats = @this.boats
  end
end

