class FlaggingsController < ApplicationController

  hobo_model_controller

  auto_actions :all

  def create
    params[:flagging][:spotter_id] = current_user
    hobo_create do | responds_to |
      responds_to.xml { render }
    end
  end
  def destroy
    hobo_destroy do | responds_to |
      responds_to.xml { render }
    end
  end

end
