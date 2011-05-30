require File.dirname(__FILE__) + '/../test_helper'

class RegistrationRoleTest < ActiveSupport::TestCase
  context "Active Record" do
    setup {@registration_role = Factory :registration_role}
    subject {@registration_role}
    should belong_to :event #PARENT
    should have_many :registrations
    should have_many :enrollments
    should validate_presence_of :name
    should validate_presence_of :operation
    should validate_uniqueness_of(:name).scoped_to(:event_id)

    should "have ':external_markdown' field" do
      assert subject.respond_to?(:external_markdown)
      assert subject.respond_to?(:'external_markdown=')
      subject.external_markdown = nil
      subject.save!
      assert_equal nil, subject.external_markdown
      subject.external_markdown = "test"
      subject.save!
      assert_equal "test", subject.external_markdown
    end
  end
end
