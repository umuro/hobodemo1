require 'test_helper'

class EtagModelTest < ActiveSupport::TestCase
  class << self
    def build_klass
      klass = Class.new( ActiveRecord::BaseWithoutTable )
      klass.stubs(:name).returns('TestModel')
        object = klass.new
        object.stubs(:id).returns(1)
        object.stubs(:updated_at).returns(Time.now)
      klass.stubs(:find).with(object.id).returns(object)
      klass.stubs(:new).returns(object)
      return klass
    end
  end

  context "A model class" do
    setup do
      @klass = self.class.build_klass
    end
    subject {@klass}
    should "aquire etag" do
      assert !@klass.new.respond_to?( :etag )
      @klass.has_etag
      assert @klass.new.respond_to?( :etag )
    end
    context "with etag" do
      setup do
        @klass.has_etag
      end
      subject {@klass}
      should "answer etag_for" do
        et = subject.etag_for 1
      end
      context ": its object" do
        setup {@object = @klass.new}
        subject {@object}
        should "answer etag" do
          et = subject.etag
          assert_not_nil et
          assert_equal et, subject.class.etag_for(subject.id)
          assert_equal subject.class.name, et[:klass]
          assert_equal subject.id, et[:id]
          assert_equal subject.updated_at.utc.tv_sec, et[:mtime]
        end
        context ": its etag" do
          setup {@etag = @object.etag}
          subject {@etag}
          should "have distinguishing to_s" do
            s = subject.to_s
            Rails.logger.debug "#{subject} have distinguishing to_s #{s}"
            assert s[subject[:klass].to_s]
            assert s[subject[:id].to_s]
            assert s[subject[:mtime].to_s]
          end
        end
      end
    end
  end

end
