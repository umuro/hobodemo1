class Flagging < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    flagging_time :datetime
    timestamps
  end
  belongs_to :spotter, :class_name => "User"
  belongs_to :flag
  belongs_to :race


  # --- Permissions --- #

  def create_permitted?
    acting_user.signed_up?
  end

  def update_permitted?
    acting_user.signed_up?
  end

  def destroy_permitted?
    acting_user.signed_up?
  end

  def view_permitted?(field)
    true
  end

end
