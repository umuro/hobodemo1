class BoatsController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => [ :index ]
  auto_actions_for :owner, [:index, :new, :create]

  smart_form_setup

  def edit_equipment
    @this=Boat.find params[:id]
    @this.try(:ensure_equipment)
    transition_page_action :edit_equipment
  end
end
