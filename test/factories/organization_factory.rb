#test/factories/organzation.rb
require 'factory_girl'
unless Factory.factories[:organization]
  
  Factory.define :organization do |m|
    m.sequence(:name) {|n| "Test Organization #{n}"}
  end
  
end

