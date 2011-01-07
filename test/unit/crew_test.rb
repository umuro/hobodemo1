require File.dirname(__FILE__) + '/../test_helper'

class CrewTest < ActiveSupport::TestCase

  context "ActiveRecord" do

    setup do
      @crew = Factory(:crew)
    end

    context "fields" do
      should have_db_column(:name).of_type(:string)
#       should have_db_index(:name)
    end

    context "validations" do
      should validate_presence_of :name
      should validate_uniqueness_of(:name).scoped_to(:owner_id)
    end

    context "relations" do
      should have_many(:crew_memberships).dependent(:destroy)
      should belong_to(:owner)
    end

  end

end