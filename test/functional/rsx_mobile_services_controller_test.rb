require File.dirname(__FILE__) + '/../test_helper'

require File.dirname(__FILE__) + '/../rsx_mobile_service_helper.rb'

class RsxMobileServicesControllerTest < ActionController::TestCase

  # Asserts whether or not there is an error in the XML according to the given schema
  def assert_no_raise_on_schema doc, schema_file
    schema = nil
    File.open schema_file do |f|
      schema = Nokogiri::XML::RelaxNG f
    end
    assert_nothing_raised {
      schema.validate(doc).each do |error|
        raise error.message
      end
    }
  end

  context "mockup" do
    setup do
      Resque.__metaclass__.send(:alias_method_chain, :enqueue, :stubbing)
      Redis.__metaclass__.send(:alias_method_chain, :current, :stubbing)
    end
    
    teardown do
      Resque.__metaclass__.send(:alias_method, :enqueue, :enqueue_without_stubbing)
      Resque.__metaclass__.send(:remove_method, :enqueue_without_stubbing)
      Redis.__metaclass__.send(:alias_method, :current, :current_without_stubbing)
      Redis.__metaclass__.send(:remove_method, :current_without_stubbing)
    end

    context "lifecycle actions" do
      setup do
        @rms_object = RsxMobileService::Lifecycle.ready(Factory(:user))
        @rms_object.event = Factory :event
        @secure = $SECURITY[:rsx_mobile_service]
      end

      context "(show existing mobile service record)" do
        
        setup do
          @rms_object.save!
          @api_key = @rms_object.api_key
          @rms_object
        end
        
        should "show pkcs5 encrypted data" do
          @request.env['X-Key'] = @api_key
          @request.accept = 'application/pkcs5'
          get :show, :id => @rms_object.event.id
          assert_response :success
          assert_match 'application/pkcs5', @response.headers['Content-Type']
          xml = @secure.decrypt @response.body
          doc = Nokogiri::XML(xml)
          assert_no_raise_on_schema doc, File.join(RAILS_ROOT, 'public', 'schema', 'data.rnc')
          assert_not_equal @api_key, doc.xpath('//key/text()').to_s
        end
        
        
        should "not show unencrypted data" do
          get :show, :id => @rms_object.id
          assert_response :forbidden
        end
        
      end
      
      context "(post position update)" do
        
        setup do
          @rms_object.save!
          @api_key = @rms_object.api_key
          @rms_object
        end
        
        should "not tolerate post without proper id" do
          @request.env['RAW_POST_DATA'] = 'some stuff'
          post :position_update, :id => -1 # use -1. as this will not exist
          @request.env.delete('RAW_POST_DATA')
          schema = nil
          doc = Nokogiri::XML @response.body
          assert_no_raise_on_schema doc, File.join(RAILS_ROOT, 'public', 'schema', 'error.rnc')
          assert_equal 2, doc.xpath('//code/text()').to_s.to_i
        end
        
        should "not tolerate post without api-key" do
          @request.env['RAW_POST_DATA'] = 'some stuff'
          post :position_update, :id => @rms_object.event.id
          @request.env.delete('RAW_POST_DATA')
          schema = nil
          doc = Nokogiri::XML @response.body
          assert_no_raise_on_schema doc, File.join(RAILS_ROOT, 'public', 'schema', 'error.rnc')
          assert_equal 1, doc.xpath('//code/text()').to_s.to_i
        end
        
        context "[with a data fragment]" do
          
          setup do
            @fleet_race = UseCaseSamples.build_fleet_race
            fleet_race_membership = Factory :fleet_race_membership, :fleet_race=>@fleet_race
            fleet_race_membership2 = Factory :fleet_race_membership, :fleet_race => @fleet_race
            race = fleet_race_membership.fleet_race.race
            race.event = @rms_object.event
            race.save!
            @course = @fleet_race.course

            found_spots = Spot.all :conditions=>{:course_id => @course.id}
            found_spots.*.destroy
            (1..4).each do |n|
              spot = Spot.create!(:position => n, :course => @course, :spot_type => Spot::SpotType::MARK)
            end
            Spot.create!(:course => @course, :spot_type => Spot::SpotType::REPORT)
            Spot.create!(:course => @course, :spot_type => Spot::SpotType::OCS)
            Spot.create!(:course => @course, :spot_type => Spot::SpotType::FINISH)
            @api_key = @rms_object.api_key
            @rms_object
          end
          
          should "pass with a buoy // spotting" do
            count1 = Spotting.count
            boats = @fleet_race.boats
            doc = Nokogiri::XML::Builder.new do |xml|
              xml.send(:'position-update') {
                for boat in boats
                  assert_not_nil boat
                  xml.position('boat-id' => boat.id, 'time' => DateTime.now, 'fleet-race-id' => @fleet_race.id) {
                    xml.buoy rand(3) + 1
                  }
                end
              }
            end
            encrypted = @secure.encrypt doc.to_xml
            
            @request.env['RAW_POST_DATA'] = encrypted
            @request.env['X-Key'] = @api_key
            @request.accept = 'application/pkcs5'
            post :position_update, :id => @rms_object.event.id
            @request.env.delete('RAW_POST_DATA')
            assert_response :success
            count2 = Spotting.count
            doc = Nokogiri::XML $SECURITY[:rsx_mobile_service].decrypt(@response.body)
            assert_no_raise_on_schema doc, File.join(RAILS_ROOT, 'public', 'schema', 'position-update-success.rnc')
            assert_not_equal @api_key, doc.xpath('//key/text()').to_s
            
            assert_not_equal count1, count2
          end
          

          should "pass with a buoy and start flag // spotting" do
            count1 = Spotting.count
            boats = @fleet_race.boats
            doc = Nokogiri::XML::Builder.new do |xml|
              xml.send(:'position-update') {
                for boat in boats
                  assert_not_nil boat              
                  xml.position('boat-id' => boat.id, 'time' => DateTime.now, 'fleet-race-id' => @fleet_race.id) {
                    xml.buoy rand(3) + 1
                    xml.flag "start"
                  }
                end
              }
            end
            encrypted = @secure.encrypt doc.to_xml
            
            @request.env['RAW_POST_DATA'] = encrypted
            @request.env['X-Key'] = @api_key
            @request.accept = 'application/pkcs5'
            post :position_update, :id => @rms_object.event.id
            @request.env.delete('RAW_POST_DATA')
            assert_response :success
            count2 = Spotting.count
            doc = Nokogiri::XML $SECURITY[:rsx_mobile_service].decrypt(@response.body)
            assert_no_raise_on_schema doc, File.join(RAILS_ROOT, 'public', 'schema', 'position-update-success.rnc')
            assert_not_equal @api_key, doc.xpath('//key/text()').to_s
            
            assert_equal count1 + boats.size * 2, count2
          end
          
          should "pass with a buoy using a report position // spotting" do
            count1 = (Spotting.all.reject {|s| (s.spot.spot_type != Spot::SpotType::REPORT)}).count
            boats = @fleet_race.boats
            doc = Nokogiri::XML::Builder.new do |xml|
              xml.send(:'position-update') {
                for boat in boats
                  assert_not_nil boat              
                  xml.position('boat-id' => boat.id, 'time' => DateTime.now, 'fleet-race-id' => @fleet_race.id) {
                    xml.buoy 1
                  }
                end
              }
            end
            encrypted = @secure.encrypt doc.to_xml
            
            @request.env['RAW_POST_DATA'] = encrypted
            @request.env['X-Key'] = @api_key
            @request.accept = 'application/pkcs5'
            post :position_update, :id => @rms_object.event.id
            @request.env.delete('RAW_POST_DATA')
            assert_response :success
            count2 = (Spotting.all.reject {|s| (s.spot.spot_type != Spot::SpotType::REPORT)}).count
            doc = Nokogiri::XML $SECURITY[:rsx_mobile_service].decrypt(@response.body)
            assert_no_raise_on_schema doc, File.join(RAILS_ROOT, 'public', 'schema', 'position-update-success.rnc')
            assert_not_equal @api_key, doc.xpath('//key/text()').to_s
            @api_key = doc.xpath('//key/text()').to_s
            
            assert_equal count1 + boats.size, count2
          end
          
          should "pass with a buoy using a mark position // spotting" do
            @fleet_race.start_time = DateTime.now
            @fleet_race.save!
            count1 = (Spotting.all.reject {|s| (s.spot.spot_type != Spot::SpotType::MARK)}).count
            boats = @fleet_race.boats
            doc = Nokogiri::XML::Builder.new do |xml|
              xml.send(:'position-update') {
                for boat in boats
                  assert_not_nil boat              
                  xml.position('boat-id' => boat.id, 'time' => DateTime.now, 'fleet-race-id' => @fleet_race.id) {
                    xml.buoy 1
                  }
                end
              }
            end
            encrypted = @secure.encrypt doc.to_xml
            
            @request.env['RAW_POST_DATA'] = encrypted
            @request.env['X-Key'] = @api_key
            @request.accept = 'application/pkcs5'
            post :position_update, :id => @rms_object.event.id
            @request.env.delete('RAW_POST_DATA')
            assert_response :success
            count2 = (Spotting.all.reject {|s| (s.spot.spot_type != Spot::SpotType::MARK)}).count
            doc = Nokogiri::XML $SECURITY[:rsx_mobile_service].decrypt(@response.body)
            assert_no_raise_on_schema doc, File.join(RAILS_ROOT, 'public', 'schema', 'position-update-success.rnc')
            assert_not_equal @api_key, doc.xpath('//key/text()').to_s
            @api_key = doc.xpath('//key/text()').to_s
            
            assert_equal count1 + boats.size, count2
          end
          
          should "pass with a buoy using a report position although a start time is already set // spotting" do
            @fleet_race.start_time = DateTime.now
            @fleet_race.save!
            count1 = (Spotting.all.reject {|s| (s.spot.spot_type != Spot::SpotType::REPORT)}).count
            boats = @fleet_race.boats
            doc = Nokogiri::XML::Builder.new do |xml|
              xml.send(:'position-update') {
                for boat in boats
                  assert_not_nil boat
                  xml.position('boat-id' => boat.id, 'time' => (@fleet_race.start_time - 1.hours).to_datetime, 'fleet-race-id' => @fleet_race.id) {
                    xml.buoy 1
                  }
                end
              }
            end
            encrypted = @secure.encrypt doc.to_xml
            
            @request.env['RAW_POST_DATA'] = encrypted
            @request.env['X-Key'] = @api_key
            @request.accept = 'application/pkcs5'
            post :position_update, :id => @rms_object.event.id
            @request.env.delete('RAW_POST_DATA')
            assert_response :success
            count2 = (Spotting.all.reject {|s| (s.spot.spot_type != Spot::SpotType::REPORT)}).count
            doc = Nokogiri::XML $SECURITY[:rsx_mobile_service].decrypt(@response.body)
            assert_no_raise_on_schema doc, File.join(RAILS_ROOT, 'public', 'schema', 'position-update-success.rnc')
            assert_not_equal @api_key, doc.xpath('//key/text()').to_s
            @api_key = doc.xpath('//key/text()').to_s
            
            assert_equal count1 + boats.size, count2
          end
          
          should "pass with a buoy and finish flag // spotting" do
            count1 = Spotting.count
            boats = @fleet_race.boats
            doc = Nokogiri::XML::Builder.new do |xml|
              xml.send(:'position-update') {
                for boat in boats
                  assert_not_nil boat              
                  xml.position('boat-id' => boat.id, 'time' => DateTime.now, 'fleet-race-id' => @fleet_race.id) {
                    xml.buoy rand(3) + 1
                    xml.flag "finish"
                  }
                end
              }
            end
            encrypted = @secure.encrypt doc.to_xml
            
            @request.env['RAW_POST_DATA'] = encrypted
            @request.env['X-Key'] = @api_key
            @request.accept = 'application/pkcs5'
            post :position_update, :id => @rms_object.event.id
            @request.env.delete('RAW_POST_DATA')
            assert_response :success
            count2 = Spotting.count
            doc = Nokogiri::XML $SECURITY[:rsx_mobile_service].decrypt(@response.body)
            assert_no_raise_on_schema doc, File.join(RAILS_ROOT, 'public', 'schema', 'position-update-success.rnc')
            assert_not_equal @api_key, doc.xpath('//key/text()').to_s
            
            assert_equal count1 + boats.size * 2, count2
          end

          should "not pass an invalid flag // spotting" do
            count1 = Spotting.count
            boats = @fleet_race.boats
            doc = Nokogiri::XML::Builder.new do |xml|
              xml.send(:'position-update') {
                for boat in boats
                  assert_not_nil boat              
                  xml.position('boat-id' => boat.id, 'time' => DateTime.now, 'fleet-race-id' => @fleet_race.id) {
                    xml.buoy rand(3) + 1
                    xml.flag "some_funny_invalid_flag"
                  }
                end
              }
            end
            encrypted = @secure.encrypt doc.to_xml
            
            @request.env['RAW_POST_DATA'] = encrypted
            @request.env['X-Key'] = @api_key
            @request.accept = 'application/pkcs5'
            post :position_update, :id => @rms_object.event.id
            @request.env.delete('RAW_POST_DATA')
            assert_response :success
            count2 = Spotting.count
            doc = Nokogiri::XML $SECURITY[:rsx_mobile_service].decrypt(@response.body)
            assert_no_raise_on_schema doc, File.join(RAILS_ROOT, 'public', 'schema', 'position-update-success.rnc')
            assert_not_equal @api_key, doc.xpath('//key/text()').to_s
            
            assert_equal count1 + boats.size, count2
          end
        end
      end
    end
  end
end
