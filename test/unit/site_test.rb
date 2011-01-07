require File.dirname(__FILE__) + '/../test_helper'

class SiteTest < ActiveSupport::TestCase
  context "A Site" do
    subject {Site.current}

    should "have etag always" do
#       FileUtils.rm Site.file_to_touch if File.exist?(Site.file_to_touch)
#       t1 = Site.etag_for subject.id
#       FileUtils.rm Site.file_to_touch if File.exist?(Site.file_to_touch)
#       t2 = Site.etag_for subject.id
#       assert_equal t1, t2
    end
    should "have proper etag" do
#       assert_equal subject.class.name, subject.etag[:klass]
#       assert_equal subject.id, subject.etag[:id]
#       assert_equal subject.updated_at.utc.tv_sec, subject.etag[:mtime]
    end
  end #context

  context "A site with content" do

  end #context
end
