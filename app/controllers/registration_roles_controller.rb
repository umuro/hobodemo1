class RegistrationRolesController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => [:index]
  auto_actions_for :event, [:index, :new, :create]
end