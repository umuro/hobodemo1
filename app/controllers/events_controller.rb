class EventsController < ApplicationController
  @umur = 'somewhere'
  hobo_model_controller

  auto_actions_for :event_folder, [:index, :new, :create]
  auto_actions :all, :except => :index
  # auto_actions_for :event_spotters, [:index] (done as seperate action due to view_hints incompatibility issues [multiple event_folders])
#   auto_actions :read_only, :except => :index

  smart_form_setup
  
  index_action :active do
    hobo_index Event.active
  end
    
  show_action :todays_active_fleet_races do
    hobo_show
    @todays_active_fleet_races = @this.fleet_races.today_for(@this).active
  end

  show_action :shop do
    hobo_show do
    end
  end

  show_action :enrollments do
    hobo_show
    @fields = %w[boat crew country gender state date_measured paid insured measured]
    respond_to do |format|
      format.csv { render_csv("enrollments-#{@this.id}-#{Time.now.strftime("%Y%m%d")}") }
    end
  end

  show_action :registrations do
    hobo_show
    @fields = %w[registration_role owner state]
    respond_to do |format|
      format.csv { render_csv("registrations-#{@this.id}-#{Time.now.strftime("%Y%m%d")}") }
    end
  end
end
