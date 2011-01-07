require File.dirname(__FILE__) + '/../test_helper'

class UserProfileTest < ActiveSupport::TestCase

  context "ActiveRecord" do

    context "fields" do
      should have_db_column(:first_name).of_type(:string)
      should have_db_column(:middle_name).of_type(:string)
      should have_db_column(:last_name).of_type(:string)
      should have_db_column(:gender)
      should have_db_column(:if_person_id).of_type(:string)
      should have_db_column(:birthdate).of_type(:date)
    end

    context "validations" do
      should validate_presence_of(:country)
      should validate_presence_of(:owner)
    end

    context "relations" do
      should belong_to(:owner)
      should belong_to(:country)
    end

  end
  
  context "With subject to be a user profile" do
    subject { Factory :user_profile }
  
    context "Hyperlinks" do
      
      
      should "not be able to save with an illegal URL" do
        ["mailto:illegal@illegal.com", "file:///illegalfs"].each do |uri|
          [:'twitter=', :'facebook=', :'homepage='].each do |m|
            subject.send m, uri
            assert_raise(ActiveRecord::RecordInvalid) { subject.save! }
          end
        end
      end
      
      should "be able to assign valid URL's" do
        ["http://www.test.com", "https://www.test.com", "www.test.com"].each do |uri|
          [:'twitter=', :'facebook=', :'homepage='].each do |m|
            subject.send m, uri
            assert subject.save!
          end
        end
      end

      should "make www.test.com to become http://www.test.com" do
        [:'twitter', :'facebook', :'homepage'].each do |m|
          subject.send "#{m}=".to_sym, "www.test.com"
          subject.save!
          assert_equal subject.send(m), "http://www.test.com"
        end
      end

    end
  
    context "Name" do
      
      # ** I M P O R T A N T **
      #
      # In countries different from Western Countries (such as some Asian countries), it is not always common
      # to have a first name or last name. Rather, it is common to have a name as a set of names, where there is no 
      # particular difference between first/middle/last name. For that, the first and last names are not required.
      # Within the west itself, middle names are also absent in many names.
      
      should "be possible to have first name nil" do
        subject.first_name = nil
        assert subject.save!
      end
      
      should "be possible to have first name empty" do
        subject.first_name = ""
        assert subject.save!
      end

      should "be possible to have middle name nil" do
        subject.middle_name = nil
        assert subject.save!
      end
      
      should "be possible to have middle name empty" do
        subject.middle_name = ""
        assert subject.save!
      end
      
      should "be possible to have last name not nil" do
        subject.last_name = nil
        assert_raise(ActiveRecord::RecordInvalid) {subject.save!}
      end
      
      should "be possible to have last name not empty" do
        subject.last_name = ""
        assert_raise(ActiveRecord::RecordInvalid) {subject.save!}
      end


    end
  end
end
