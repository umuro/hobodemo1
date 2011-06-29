class CoursesController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except=> [:new, :create, :index]
  # auto_actions_for :organization, [:index, :new, :create] - Done in TemplateCoursesController

  smart_form_setup
  
end
