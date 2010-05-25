require File.dirname(__FILE__) + '/../test_helper'

class SitesControllerTest < ActionController::TestCase
  context "A Sites Controller" do
    context "with a site" do
      setup {@site = Site.current}
      should "show" do
        get :show, :id=>@site.id
        assert_response :success
      end
    end
  end #context
end
