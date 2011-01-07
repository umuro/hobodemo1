# #lib/tasks/gp_populate.rake
# 
# namespace :gp do
# 
#   desc "Giorgio's fill the database task"
# 
#   task :populate => [:environment, 'db:reset'] do
# 
#     require 'factory_girl'
# 
#     Factory.define :admin, :class => "User" do |u|
#       u.email_address 'admin@boat.com'
#       u.password 'pass'
#       u.administrator true
#     end
# 
#     Factory.define :user do |u|
#       u.password 'pass'
#       u.administrator false
#     end
# 
#     Factory.define :boat do |b|
#       b.sequence(:sail_number) { |n| "sail_nr_#{n}" }
#     end
# 
#     Factory.define :boat_class do |bc|
#       bc.name
#       bc.description
#       bc.no_of_crew_members 
#     end
# 
#     Factory(:admin)
#     Factory(:user, :email_address=>'mike.tyson@boat.com') 
#     Factory(:user, :email_address=>'karl.smith@boat.com')
# 
#     #TODO Boat, BoatClass
#     
# 
#   end
# 
# end