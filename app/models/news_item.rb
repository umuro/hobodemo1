class NewsItem < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    title  :string
    body   :text
    #FIXME status news life cycle
    timestamps
  end

  belongs_to :news, :polymorphic => true

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
