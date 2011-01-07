#test/factories/user.rb
require 'factory_girl'

unless Factory.factories[:user]

  Factory.define :admin, :class => User do |u|
    u.sequence(:email_address ){ |n| "admin_#{n}@test.com"}
    u.password 'pass'
    u.state 'active'
    u.administrator true
  end

  Factory.define :user do |u|
    u.state 'active'
    u.sequence(:email_address ){ |n| "user_#{n}@test.com"}
    u.password 'pass'
    u.administrator false
  end

end
