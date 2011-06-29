class RacesController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => :index
  auto_actions_for :event, [:index, :new, :create]

  smart_form_setup
end

