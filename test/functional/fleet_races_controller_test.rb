require File.dirname(__FILE__) + '/../test_helper'
require 'test/factories/use_case_samples'
# Mobile Client

class FleetRacesControllerTest < ActionController::TestCase

  context "Guest" do

    setup do
      admin = Factory(:user_profile).owner
      @race = Factory(:race)
      @race.organization.organization_admins = [admin]
      @race.save

      @course_area = Factory(:course_area, :event=>@race.event)
      @course = UseCaseSamples.build_course :organization=>@race.organization

      time = DateTime.now.in_time_zone(@race.event.time_zone)

      @fleet_race_params = {:course_id => @course.id, 
                            :course_area_id => @course_area.id,
                            :scheduled_time => time,
                            :color => 'Green', 
                            :status => 'Open', 
                            :race_id => @race.id}

      @fleet_race = UseCaseSamples.build_fleet_race :race=>@race

    end #setup

    context "CRUD actions" do

      context "write actions" do
        
        should "not post #create_for_race" do
          post :create_for_race, :race_id=>@race.id, 
               :fleet_race=> @fleet_race_params
          assert_response :forbidden
        end
      end #write actions

      context "read actions" do

        should "get index" do
          get :index
          assert_response :success
        end

        should "get show" do
          get :show, :id => @fleet_race.id
          assert_response :success
        end
      end #read actions

      context "edit actions" do
        
        should "not get #new_for_race" do
          get :new_for_race, :race_id=>@race.id
          assert_response :success
          assert_no_tag :tag => 'form'
        end

        should "not get new" do
          get :new
          assert_response :success
          assert_no_tag :tag => 'form'
        end

        should "not get edit" do
          get :edit, :id => @fleet_race.id
          assert_response :success
          assert_no_tag :tag => 'form'
        end

        context "put update" do

          should "fail for #color" do
            new_color = 'Gold'

            put :update, :id=>@fleet_race.id, :fleet_race => {:color=>new_color}
            assert_response :forbidden

            fleet_race = FleetRace.find(@fleet_race.id)
            assert_not_equal fleet_race.color, new_color
          end

          should "fail for #status" do
            new_status = 'Unknown'

            put :update, :id=>@fleet_race.id, :fleet_race => {:status=>new_status}
            assert_response :forbidden

            fleet_race = FleetRace.find(@fleet_race.id)
            assert_not_equal fleet_race.status, new_status
          end

          should "fail for #scheduled_time" do
            old_time = @fleet_race.scheduled_time
            time_zone = @fleet_race.event.time_zone
            new_time = DateTime.now.in_time_zone(time_zone) + 1.day

            put :update, :id=>@fleet_race.id, :fleet_race=>{:scheduled_time=>new_time}
            assert_response :forbidden

            fleet_race = FleetRace.find(@fleet_race.id)
            scheduled_time = fleet_race.scheduled_time.in_time_zone(time_zone)

            assert_equal scheduled_time, old_time
          end

          should "fail for #course" do
            new_course = UseCaseSamples.build_course :organization=>@race.organization
            
            fleet_race_id = @fleet_race.id
            course_id = @fleet_race.course.id

            assert_equal @fleet_race.course_id, @fleet_race.course.id
            assert_not_nil fleet_race_id
            assert_not_nil course_id

            put :update, :id=>@fleet_race.id, :fleet_race=>{:course_id=>new_course.id}
            assert_response :forbidden

            fleet_race = FleetRace.find(@fleet_race.id)

            assert_not_nil fleet_race.course
            assert_equal fleet_race.id, fleet_race_id
            assert_equal course_id, fleet_race.course_id
          end

          should "fail for #course_area" do
            new_course_area = Factory(:course_area, :event=>@race.event)

            put :update, :id=>@fleet_race.id, 
                :fleet_race => {:course_area_id=>new_course_area.id}
            assert_response :forbidden

            fleet_race = FleetRace.find(@fleet_race.id)
            assert_not_equal fleet_race.course_area, new_course_area
          end
        end #put update
      end #edit actions
    end #CRUD actions
  end #Guest

  context "User" do

    setup do
      admin = Factory(:user_profile).owner
      @race = Factory(:race)
      @race.organization.organization_admins = [admin]
      @race.save
      
      @course_area = Factory(:course_area, :event=>@race.event)
      @course = UseCaseSamples.build_course :organization=>@race.organization

      time = DateTime.now.in_time_zone(@race.event.time_zone)

      @fleet_race_params = {:course_id => @course.id, 
                            :course_area_id => @course_area.id,
                            :scheduled_time => time,
                            :color => 'Green', 
                            :status => 'Open', 
                            :race_id => @race.id}

      @fleet_race = UseCaseSamples.build_fleet_race :race=>@race

      user = Factory(:user_profile).owner
      login_as user
    end #setup

    teardown do
      logout
    end

    context "CRUD actions" do

      context "write actions" do
        
        should "not post #create_for_race" do
          post :create_for_race, :race_id=>@race.id, 
               :fleet_race=> @fleet_race_params
          assert_response :forbidden
        end
      end #write actions

      context "read actions" do

        should "get index" do
          get :index
          assert_response :success
        end

        should "get show" do
          get :show, :id => @fleet_race.id
          assert_response :success
        end
      end #read actions

      context "edit actions" do

        should "not get #new_for_race" do
          get :new_for_race, :race_id=>@race.id
          assert_response :success
          assert_no_tag :tag => 'form'
        end

        should "not get new" do
          get :new
          assert_response :success
          assert_no_tag :tag => 'form'
        end

        should "not get edit" do
          get :edit, :id => @fleet_race.id
          assert_response :success
          assert_no_tag :tag => 'form'
        end

        context "put update" do

          should "fail for #color" do
            new_color = 'Gold'

            put :update, :id=>@fleet_race.id, :fleet_race=>{:color=>new_color}
            assert_response :forbidden

            fleet_race = FleetRace.find(@fleet_race.id)
            assert_not_equal fleet_race.color, new_color
          end

          should "fail for #status" do
            new_status = 'Unknown'

            put :update, :id=>@fleet_race.id, :fleet_race=>{:status=>new_status}
            assert_response :forbidden

            fleet_race = FleetRace.find(@fleet_race.id)
            assert_not_equal fleet_race.status, new_status
          end

          should "fail for #scheduled_time" do
            old_time = @fleet_race.scheduled_time
            time_zone = @fleet_race.event.time_zone
            new_time = DateTime.now.in_time_zone(time_zone) + 1.day

            put :update, :id=>@fleet_race.id, :fleet_race=>{:scheduled_time=>new_time}
            assert_response :forbidden

            fleet_race = FleetRace.find(@fleet_race.id)
            scheduled_time = fleet_race.scheduled_time.in_time_zone(time_zone)

            assert_equal scheduled_time, old_time
          end

          should "fail for #course" do
            new_course = UseCaseSamples.build_course :organization=>@race.organization

            fleet_race_id = @fleet_race.id
            course_id = @fleet_race.course.id

            assert_equal @fleet_race.course_id, @fleet_race.course.id
            assert_not_nil fleet_race_id
            assert_not_nil course_id

            put :update, :id=>@fleet_race.id, :fleet_race=>{:course_id=>new_course.id}
            assert_response :forbidden

            fleet_race = FleetRace.find(@fleet_race.id)

            assert_not_nil fleet_race.course
            assert_equal fleet_race.id, fleet_race_id
            assert_equal course_id, fleet_race.course_id
          end

          should "fail for #course_area" do
            new_course_area = Factory(:course_area, :event=>@race.event)

            put :update, :id=>@fleet_race.id, 
                :fleet_race => {:course_area_id=>new_course_area.id}
            assert_response :forbidden

            fleet_race = FleetRace.find(@fleet_race.id)
            assert_not_equal fleet_race.course_area, new_course_area
          end
        end #put update
      end #edit actions
    end #CRUD actions
  end #User

  context "Organization Admin" do

    setup do
      admin = Factory(:user_profile).owner
      @race = Factory(:race)
      @race.organization.organization_admins = [admin]
      @race.save
      
      @course_area = Factory(:course_area, :event=>@race.event)
      @course = UseCaseSamples.build_course :organization=>@race.organization

      time = Time.now.in_time_zone(@race.event.time_zone)

      @fleet_race_params = {:course_id => @course.id,
                            :course_area_id => @course_area.id,
                            :scheduled_time => time,
                            :color => 'Green', 
                            #:status => 'Open', 
                            :race_id => @race.id}

      @fleet_race = UseCaseSamples.build_fleet_race :race=>@race

      login_as admin
    end #setup

    teardown do
      logout
    end

    context "CRUD actions" do

      context "write actions" do
        
        should "post #create_for_race" do
          post :create_for_race, :race_id=>@race.id, 
               :fleet_race=> @fleet_race_params
          assert_response :found
        end
        
        should "post #create_for_race where scheduled time is nil" do
          @fleet_race_params[:scheduled_time] = nil
          post :create_for_race, :race_id=>@race.id, 
               :fleet_race=> @fleet_race_params
          assert_response :found
          assert_not_nil Race.find(@race.id).fleet_races.first(
            :conditions => {:color => @fleet_race_params[:color],
                            :scheduled_time => @fleet_race_params[:scheduled_time],
                            :course_area_id => @fleet_race_params[:course_area_id]})
        end
        
      end #write actions

      context "read actions" do

        should "get index" do
          get :index
          assert_response :success
        end

        should "get show" do
          get :show, :id => @fleet_race.id
          assert_response :success
        end
      end #read actions

      context "edit actions" do
        
        should "get #new_for_race" do
          get :new_for_race, :race_id=>@race.id
          assert_response :success
          assert_tag :tag => 'form'
          
          # The scheduled time should be proposed
          assert_tag :tag => 'input', :attributes => { :id => 'fleet_race_scheduled_time', :value => /.*/ }
        end

        should "not get new" do
          get :new
          assert_response :success
          assert_no_tag :tag => 'form'
        end

        should "get edit" do
          get :edit, :id => @fleet_race.id
          assert_response :success
          assert_tag :tag => 'form'
        end

        context "put update" do
        
          should "succeed for #color" do
            new_color = 'Gold'

            put :update, :id=>@fleet_race.id, :fleet_race=>{:color=>new_color}
            assert_response :found

            fleet_race = FleetRace.find(@fleet_race.id)
            assert_equal fleet_race.color, new_color
          end

          should "fail for #status before race" do
            new_status = 'Unknown'
            
            Delorean.time_travel_to @fleet_race.scheduled_time - 1.days do
              put :update, :id=>@fleet_race.id, :fleet_race=>{:status=>new_status}
              assert_response :forbidden
            end

            fleet_race = FleetRace.find(@fleet_race.id)
            assert_not_equal fleet_race.status, new_status
          end

          should "succeed for #status after race" do
            new_status = 'Unknown'

            Delorean.time_travel_to @fleet_race.scheduled_time + 1.days do
              put :update, :id=>@fleet_race.id, :fleet_race=>{:status=>new_status}
              assert_response :found
            end

            fleet_race = FleetRace.find(@fleet_race.id)
            assert_equal fleet_race.status, new_status
          end
          
          should "fail for #start_time before race" do
            new_start_time = DateTime.now.utc
            
            Delorean.time_travel_to @fleet_race.scheduled_time - 1.days do
              put :update, :id=>@fleet_race.id, :fleet_race=>{:start_time=>new_start_time}
              assert_response :forbidden
            end

            fleet_race = FleetRace.find(@fleet_race.id)
            assert_nil fleet_race.start_time
          end

          should "succeed for #start_time after race" do
            new_start_time = DateTime.now.utc
            
            Delorean.time_travel_to @fleet_race.scheduled_time + 1.days do
              put :update, :id=>@fleet_race.id, :fleet_race=>{:start_time=>new_start_time}
              assert_response :found
            end

            fleet_race = FleetRace.find(@fleet_race.id)
            assert_equal fleet_race.start_time.utc.to_i, new_start_time.utc.to_i
          end
          
          should "fail for #end_time before race" do
            new_end_time = DateTime.now.utc
            
            Delorean.time_travel_to @fleet_race.scheduled_time - 1.days do
              put :update, :id=>@fleet_race.id, :fleet_race=>{:end_time=>new_end_time}
              assert_response :forbidden
            end

            fleet_race = FleetRace.find(@fleet_race.id)
            assert_nil fleet_race.end_time
          end

          should "succeed for #end_time after race" do
            new_end_time = DateTime.now.utc
            
            Delorean.time_travel_to @fleet_race.scheduled_time + 1.days do
              put :update, :id=>@fleet_race.id, :fleet_race=>{:end_time=>new_end_time}
              assert_response :found
            end

            fleet_race = FleetRace.find(@fleet_race.id)
            assert_equal fleet_race.end_time.utc.to_i, new_end_time.utc.to_i
          end

          should "succeed for #scheduled_time" do
            old_time = @fleet_race.scheduled_time
            time_zone = @fleet_race.event.time_zone
            new_time = DateTime.now.in_time_zone(time_zone) + 1.day

            @fleet_race.scheduled_time = new_time
            assert @fleet_race.save

            put :update, :id=>@fleet_race.id, :fleet_race=>{:scheduled_time=>new_time}
            assert_response :found

            fleet_race = FleetRace.find(@fleet_race.id)
            scheduled_time = fleet_race.scheduled_time.in_time_zone(time_zone)
            assert_not_equal scheduled_time, old_time
            assert_equal scheduled_time, new_time
          end

          should "succeed for #course" do
            new_course = Factory(:course, :organization=>@race.organization)
            old_course_id = @fleet_race.course_id
            old_spots_id = @fleet_race.course.spots.*.id

            put :update, :id=>@fleet_race.id, :fleet_race=>{:course_id=>new_course.id}
            assert_response :found

            fleet_race = FleetRace.find(@fleet_race.id)
            course = fleet_race.course

            assert_not_equal old_course_id, course.id
            assert_nil course.organization_id
            assert_equal course.name, new_course.name
            assert_equal course.spots.count, new_course.spots.count

            assert_raise ActiveRecord::RecordNotFound do
              Course.find(old_course_id)
            end
            
            assert_raise ActiveRecord::RecordNotFound do
              old_spots_id.each do |spot_id|
                Spot.find(spot_id)
              end
            end
          end

          should "succeed for #course_area" do
            new_course_area = Factory(:course_area, :event=>@race.event)

            put :update, :id=>@fleet_race.id, 
                :fleet_race => {:course_area_id=>new_course_area.id}
            assert_response :found

            fleet_race = FleetRace.find(@fleet_race.id)
            assert_equal fleet_race.course_area, new_course_area
          end
        end #put update
      end #edit actions
    end #CRUD actions
  end #Guest

   context "in Spotting Story, " do
   # Mobile Client
    setup do
      @the_spotter = Factory(:user_profile).owner
#       Event.any_instance.stubs(:acting_user).returns(@the_spotter)
      @boat = UseCaseSamples.build_boat 
      @fleet_race = UseCaseSamples.build_fleet_race 
      UseCaseSamples.participate_to_fleet_race :boat => @boat, :fleet_race => @fleet_race
    end
    context "with a course area, " do
      setup {@course_area = @fleet_race.course_area}
      should "get fleet races" do
        get :index_for_course_area, :course_area_id => @course_area.id, :format=>'xml'
        assert_response :success
        klass = "FleetRace"
        assert_tag :tag=>klass.underscore.pluralize,
            :descendant => { :tag => klass.underscore }
#         assert_tag :tag => 'name',
#                              :parent => { :tag => klass.underscore },
#                              :content => /.+/
        assert_tag :tag => 'number',
                             :parent => { :tag => klass.underscore },
                             :content => /.+/
        assert_tag :tag => 'color',
                             :parent => { :tag => klass.underscore },
                             :content => /.+/
        assert_tag :tag => 'id',
                             :parent => { :tag => klass.underscore },
                             :content => /[0-9]+/
      end #should
    end #context
    context "with a fleet race, " do
      should "show" do
        assert_not_nil @fleet_race
        get :show, :id => @fleet_race.id, :format=>'xml'
        assert_response :success
        klass = "FleetRace"
#         assert_tag :tag => 'name',
#                              :parent => { :tag => klass.underscore },
#                              :content => /.+/
        assert_tag :tag => 'number',
                             :parent => { :tag => klass.underscore },
                             :content => /.+/
        assert_tag :tag => 'color',
                             :parent => { :tag => klass.underscore },
                             :content => /.+/
        assert_tag :tag => 'id',
                             :parent => { :tag => klass.underscore },
                             :content => /[0-9]+/
        assert_tag :tag => 'event_id',
                             :parent => { :tag => klass.underscore },
                             :content => /[0-9]+/
        assert_tag :tag => 'course_id',
                             :parent => { :tag => klass.underscore },
                             :content => /[0-9]+/
        assert_tag :tag => 'course_area_id',
                             :parent => { :tag => klass.underscore },
                             :content => /[0-9]+/
      end#should
      should "get flags" do
        get :flags, :id=>@fleet_race.id, :format=>'xml'
        assert_response :success
        klass = "Flag"
        assert_tag :tag=>klass.underscore.pluralize,
            :descendant => { :tag => klass.underscore }
        assert_tag :tag => 'name',
                              :parent => { :tag => klass.underscore },
                              :content => /.+/
        assert_tag :tag => 'id',
                              :parent => { :tag => klass.underscore },
                              :content => /[0-9]+/
      end #should
      should "get boats" do
        get :boats, :id=>@fleet_race.id, :format=>'xml'
        assert_response :success
        klass = "Boat"
        assert_tag :tag=>klass.underscore.pluralize,
            :descendant => { :tag => klass.underscore }
        assert_tag :tag => 'sail_number',
                              :parent => { :tag => klass.underscore },
                              :content => /.+/
        assert_tag :tag => 'id',
                              :parent => { :tag => klass.underscore },
                              :content => /[0-9]+/
      end #should
    end #context
  end #context
end #FleetRacesControllerTest
