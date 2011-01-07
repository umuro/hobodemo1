class Country < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name :string, :required, :unique, :null=>false, :index=>true
    code :string, :unique, :index=>true
    timestamps
  end

  #PAUL same person can race for different countries?
  has_many :user_profiles #locks_me
  has_many :enrollments #locks_me
  
  def destroy
    super if user_profiles.empty? && enrollments.empty?
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
