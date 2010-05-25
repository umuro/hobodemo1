class Flag < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    timestamps
    name :string, :required, :unique, :null=>false
  end


  # --- Permissions --- #

  def create_permitted?
    acting_user.administrator?
  end

  def update_permitted?
    acting_user.administrator?
  end

  def destroy_permitted?
    acting_user.administrator?
  end

  def view_permitted?(field)
    true
  end

end
