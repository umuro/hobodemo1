#test/factories/user.rb
require 'factory_girl'
unless Factory.factories[:user]

  Factory.define :admin, :class=> User do |u|
  #   u.sequence(:name ){|n| "admin#{n}"}
    u.sequence(:email_address ){|n| "admin#{n}@test.com"}
    u.password 'pass'
    u.administrator true
  end

  Factory.define :user do |u|
  #   u.sequence(:name ){|n| "user#{n}"}
    u.sequence(:email_address ){|n| "user#{n}@test.com"}
    u.password 'pass'
    u.administrator false
  end

end