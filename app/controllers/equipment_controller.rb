class EquipmentController < ApplicationController

  hobo_model_controller

  auto_actions :all
  auto_actions_for :boat, [:index, :new, :create]

end
