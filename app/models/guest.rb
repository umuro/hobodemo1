class Guest < Hobo::Guest

  def administrator?
    false
  end

  def organization_admin?( organization )
    false
  end
  
  def any_organization_admin?
    false
  end
end
