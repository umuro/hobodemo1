#to login POST /users/login :email_address, :password

require 'factory_girl'
Dir["#{RAILS_ROOT}/test/factories/*.rb"].each {|file| require file }

require 'webrat'
class ActiveSupport::TestCase
  class << self
    def context name; end
  end
end


load RAILS_ROOT+'/test/unit/use_case_test.rb'

pwd = '12345'
the_spotter = Factory(:user, :email_address=>'spotter@sailraces.org', :password=>pwd, :password_confirmation=>pwd)
boat = UseCaseTest.build_boat self
race = UseCaseTest.build_race self


#TODO: Needs to be verified.
#def assert_not_nil (a); end

o = Object.new

def o.assert_not_nil (a); end
    

UseCaseTest.participate_to_race_fleet o, {:boat => boat, :race => race}
