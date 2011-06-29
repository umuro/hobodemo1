class BoatsController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => [ :index ]
  auto_actions_for :owner, [:index, :new, :create]

  smart_form_setup
end
