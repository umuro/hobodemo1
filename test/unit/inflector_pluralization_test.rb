require File.dirname(__FILE__) + '/../test_helper'

class InflectorPluralizationTest < ActiveSupport::TestCase
  context "string series" do
    subject {"event_series"}

    should "have the same plural" do
      answer = subject.pluralize
      assert_equal "event_series", answer
    end

  end #context
  
  context "EventSeries" do
    subject {EventSeries}
    should "have correct table name" do
      assert_equal "event_series", subject.table_name
    end
  end

end
