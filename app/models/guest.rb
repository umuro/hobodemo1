class Guest < Hobo::Guest

  def administrator?
    false
  end

  def is_owner_of? an_object
    false
  end

  def organization_admin?( organization )
    false
  end
  
  def any_organization_admin?
    false
  end
  
  def id
    nil
  end
  
  def email_address
    nil
  end
end
