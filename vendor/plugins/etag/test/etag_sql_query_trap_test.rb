require 'test_helper'

class EtagSqlQueryTrapTest < ActiveSupport::TestCase
  class << self
    def build_klass
      klass = EtagModelTest.build_klass
    end
  end
  def etag_query_info
    Thread.current[:etag_query_info]
  end

  context "A model class" do
    setup do
      @klass = self.class.build_klass
    end
    subject {@klass}
    should "aquire sth" do
      subject.respond_to? :has_etag
      subject.respond_to? :caches_on_etag
    end
    context "with cache" do
      setup do
        @klass.caches_on_etag
      end
      subject {@klass}
      context ": etag_query_info" do
        subject {@klass}
        should "bypass nonselect queries" do
          qi = subject.etag_query_info('nonsense')
          assert_nil qi
        end
        should "discover table" do
          qi = subject.etag_query_info('SELECT * FROM "test_models"')
          assert_equal 'test_models', qi[:table_name]
        end
        should "bypass nonmodel queries" do
          qi = subject.etag_query_info('SELECT * FROM "sqlite_sequence"')
          assert_nil qi
        end
        should "know depended models" do
          Object.const_set('UploadSite', mock()) unless defined?(UploadSite)
          Object.const_set('Upload', stub()) unless defined?(Upload)
          q = %Q{  SELECT "uploads"."id" AS t0_r0, "uploads"."created_at" AS t0_r1, "uploads"."updated_at" AS t0_r2, "uploads"."episode_id" AS t0_r3, "uploads"."upload_site_id" AS t0_r4, "upload_sites"."id" AS t1_r0, "upload_sites"."name" AS t1_r1, "upload_sites"."regex" AS t1_r2, "upload_sites"."created_at" AS t1_r3, "upload_sites"."updated_at" AS t1_r4 FROM "uploads" LEFT OUTER JOIN "upload_sites" ON "upload_sites".id = "uploads".upload_site_id WHERE ("uploads".episode_id = 341043733) ORDER BY upload_sites.name}

          qi = subject.etag_query_info(q)
          assert qi[:depended_classes].include? Upload
          assert qi[:depended_classes].include? UploadSite
        end
        should "know depended models - episode example" do
          Object.const_set('Part', stub()) unless defined?(Part)
          Object.const_set('UploadSite', mock()) unless defined?(UploadSite)
          Object.const_set('Upload', stub()) unless defined?(Upload)
          Object.const_set('Episode', stub()) unless defined?(Episode)
          q = %Q{  SELECT "episodes"."id" AS t0_r0, "episodes"."broadcast_date" AS t0_r1, "episodes"."view_count" AS t0_r2, "episodes"."short_name" AS t0_r3, "episodes"."created_at" AS t0_r4, "episodes"."updated_at" AS t0_r5, "episodes"."serie_id" AS t0_r6, "episodes"."position" AS t0_r7, "episodes"."default_upload_id" AS t0_r8, "uploads"."id" AS t1_r0, "uploads"."created_at" AS t1_r1, "uploads"."updated_at" AS t1_r2, "uploads"."episode_id" AS t1_r3, "uploads"."upload_site_id" AS t1_r4, "parts"."id" AS t2_r0, "parts"."view_count" AS t2_r1, "parts"."url" AS t2_r2, "parts"."created_at" AS t2_r3, "parts"."updated_at" AS t2_r4, "parts"."upload_id" AS t2_r5, "parts"."position" AS t2_r6 FROM "episodes" LEFT OUTER JOIN "uploads" ON uploads.episode_id = episodes.id LEFT OUTER JOIN "parts" ON parts.upload_id = uploads.id WHERE (parts.id IS NOT NULL) ORDER BY broadcast_date DESC, episodes.position DESC
        }

          qi = subject.etag_query_info(q)
          assert qi[:depended_classes].include? Part
          assert qi[:depended_classes].include? Upload
          assert qi[:depended_classes].include? Episode
        end
      end #"etag_query_info"
      should "know if collection" do
        q = %Q{  SELECT * FROM "episodes"  ORDER BY broadcast_date DESC, episodes.position DESC}
        Object.const_set('Episode', stub()) unless defined?(Episode)
        qi = subject.etag_query_info(q)
        assert_equal Episode, qi[:class]
        assert_nil qi[:id]
      end
      should "know id" do
        q = %Q{ SELECT * FROM "episodes" WHERE ("episodes"."id" = 341043733)  ORDER BY broadcast_date DESC, episodes.position DESC}
        Object.const_set('Episode', stub()) unless defined?(Episode)
        qi = subject.etag_query_info(q)
        assert_equal Episode, qi[:class]
        assert_not_nil qi[:id]
        assert_equal 341043733, qi[:id]
      end
      should "come across count" do
        q = %Q{ SELECT count(*) AS count_all FROM "parts" WHERE}
        Object.const_set('Part', stub()) unless defined?(Part)
        qi = subject.etag_query_info(q)
        assert_equal Part, qi[:class]
        assert_nil qi[:id]
      end
  end
  end
end