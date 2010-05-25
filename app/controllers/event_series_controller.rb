class EventSeriesController < ApplicationController

  hobo_model_controller

  auto_actions_for :organization, [:index, :new, :create]
  auto_actions :all, :except => :index
#   auto_actions :read_only, :destroy, :except => :index

end
