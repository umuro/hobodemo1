class BoatClassesController < ApplicationController

  hobo_model_controller

  auto_actions_for :organization, [:index, :new, :create]
  auto_actions :all #Index is still includes becase admin sees all

end
