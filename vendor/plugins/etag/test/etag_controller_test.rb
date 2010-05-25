require 'test_helper'

class EtagControllerTest < ActiveSupport::TestCase
  def self.model_klass
    model_klass = EtagModelTest.build_klass
    model_klass.has_etag
    model_klass.stubs(:name).returns("TestModel")
    Object.const_set("TestModel", model_klass)
    return model_klass
  end
  context "A controller class" do
    setup do
      @klass = Class.new ActionController::Base
    end
    subject {@klass}
    should "aquire etag" do
      assert !@klass.new.respond_to?( :etag_cache_path )
      @klass.uses_etag
      assert @klass.new.respond_to?( :etag_cache_path )
    end
    context "using etag" do
      setup do
        @klass.uses_etag
        @model_klass = self.class.model_klass
        @klass.stubs(:name).returns(@model_klass.name.pluralize+'Controller')
      end
      subject {@klass}
      context ": its object" do
        setup do
          @controller = @klass.new

          @params = {
            :action => 'show',
            :id => 1
            }
          @controller.stubs(:params).returns(@params)

          @request = mock()
          @request.stubs(:format).returns('*/*')
          @controller.stubs(:request).returns(@request)
        end
        subject {@controller}
        should "have name matching model klass" do
          assert_equal @model_klass.name, subject.controller_name.singularize.classify
        end
        should "have cache_path" do
          p = subject.send :etag_cache_path
          assert p[subject.controller_name]
          assert p[subject.params[:action]]
          assert p['all']
          assert p[subject.request.format]
          assert p['pg:1']
        end
        if defined? Guest
          context "with Hobo" do
            setup do
                @controller.stubs(:current_user).returns(Guest.new)
            end
            subject{@controller}
            should "have cache_path" do
              p = subject.send :etag_cache_path
              assert p[subject.controller_name]
              assert p[subject.params[:action]]
              assert p[subject.current_user.administrator?.to_s]
              assert p[subject.request.format]
              assert p['pg:1']
            end
          end
        end
      end
    end
  end
end