require 'test_helper'

class EtagTest < ActiveSupport::TestCase

  context "ActiveRecord::Base" do #Etag::Model
    should "respond to has_etag" do
      assert ActiveRecord::Base.respond_to?(:has_etag)
    end
  end

  context "ActionController::Base" do #Etag::Controller
    should "respond to uses_etag" do
      assert ActionController::Base.respond_to?(:uses_etag)
    end
  end

  context "ActiveRecord::Base" do #Etag::Model::Sql::QueryTrap|Observer
    should "respond to caches_on_etag" do
      assert ActiveRecord::Base.respond_to?(:caches_on_etag)
    end
  end

end
