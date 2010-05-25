class Course < ActiveRecord::Base

  hobo_model # Don't put anything above this
  #TODO remove editor of belongs_to :race. It is master or not. Not changeable.

  fields do
    name :string
    timestamps
  end

  belongs_to :race #this is master if race is null
  has_many :spots
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
