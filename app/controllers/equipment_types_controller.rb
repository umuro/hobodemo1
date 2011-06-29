class EquipmentTypesController < ApplicationController

  hobo_model_controller

  auto_actions :all
  auto_actions_for :boat_class, [:index, :new, :create]

  smart_form_setup
end
