class SpotsController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => [:new, :create, :index]
  auto_actions_for :course, [:new, :create, :index]
  
end
