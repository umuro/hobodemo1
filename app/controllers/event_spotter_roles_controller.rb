class EventSpotterRolesController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => [:index, :new, :create]
  auto_actions_for :event, [:index, :new, :create]
  
end
