class FleetRaceMembershipsController < ApplicationController

  hobo_model_controller

  auto_actions :all #:write_only
  auto_actions_for :fleet_race, [:create]

  smart_form_setup

  def create
    hobo_create do |format|
      format.json { render :json=> this }
    end
  end

end
