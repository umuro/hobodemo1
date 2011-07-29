class BoatClassesController < ApplicationController

  hobo_model_controller

  auto_actions_for :organization, [:index, :new, :create]
  auto_actions :all, :except => :index

  smart_form_setup
end
