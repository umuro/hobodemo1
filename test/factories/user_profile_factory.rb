#test/factories/user_profile_factory.rb
require 'factory_girl'

unless Factory.factories[:user_profile]
  
Factory.define :user_profile do |up|
  up.sequence(:first_name)   { |n| "user_#{n}_fn" }
  up.sequence(:middle_name)  { |n| "user_#{n}_mn" }
  up.sequence(:last_name)    { |n| "user_#{n}_ln" }
  up.gender "Male"
  up.birthdate Date.today - 30.years
  up.country { Factory(:country) }
  up.owner { Factory(:user) }
  
  for type in [:twitter, :facebook, :homepage]
    up.sequence(type) { |n| "http://www.#{type}.com/#{n}" }
  end
  
  up.mobile_phone { rand(10**10).to_s }
end
  
end
