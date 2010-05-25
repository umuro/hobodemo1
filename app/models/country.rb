class Country < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name :string
    code :string
    timestamps
  end

  #PAUL same person can race for different countries?
  has_many :people
  has_many :team_participations

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
