class EquipmentController < ApplicationController

  hobo_model_controller

  auto_actions :read_only
  auto_actions_for :boat, [:index]

  smart_form_setup
end
