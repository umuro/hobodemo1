class Registration < ActiveRecord::Base

  hobo_model # Don't put anything above this
  abstract_registration_model

  fields do
    timestamps
  end

  def label
    "#{owner.label} as #{registration_role.name}"
  end

  def name
    label
  end 

  lifecycle do
    create :register, :params => [:registration_role],
           :become => :requested, :available_to => "User", :user_becomes => :owner
    transition :re_register, {:rejected => :requested}, :available_to=>:owner
    transition :re_register, {:retracted => :requested}, :available_to=>:owner
  end

  
end
