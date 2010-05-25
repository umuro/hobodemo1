require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase
  context "A User" do
    setup do
      @user = Factory(:user)
    end
    subject {@user}
    should "have proper etag" do
      assert_equal subject.class.name, subject.etag[:klass]
      assert_equal subject.id, subject.etag[:id]
      assert_equal subject.updated_at.utc.tv_sec, subject.etag[:mtime]
    end
    should "be deletable" do
      assert subject.destroy
    end

    context "with an organization, " do
      setup {@organization = Factory(:organization)}
      should "admin organization" do
        @organization.organization_admins << @user
        @organization.save
        assert @user.organization_admin?( @organization )
      end
    end
  end
  context "An admin" do
    setup do
      @admin = Factory(:admin)
    end
    should "admin organization" do
      assert @admin.organization_admin?( @organization )
    end
  end
end
