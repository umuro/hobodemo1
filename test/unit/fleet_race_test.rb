require File.dirname(__FILE__) + '/../test_helper'

class FleetRaceTest < ActiveSupport::TestCase

  context "Active Record" do

    setup do
      UseCaseSamples.build_fleet_race
    end

    should belong_to :race #PARENT
    should belong_to :course_area
    should belong_to :course

    should validate_presence_of :race #PARENT
    should validate_presence_of :color
    should validate_uniqueness_of(:color).scoped_to(:race_id)

    should have_many :fleet_race_memberships
    should have_many :enrollments
  end #Active Record

  context "A Fleet Race with Enrollments" do
    setup do
      fleet_race_membership = Factory :fleet_race_membership, :fleet_race=>UseCaseSamples.build_fleet_race
      @fleet_race = fleet_race_membership.fleet_race
    end
    subject {@fleet_race}
    should "provide boats" do
      boats0 = subject.fleet_race_memberships.*.enrollment.map(&:boat)
      boats = subject.boats
      assert_equal boats0.size, boats.size
      assert_equal boats0.first, boats.first
    end
  end #A Fleet Race with Enrollments

  context "A FleetRace" do

    setup do
      @race = Factory(:race)
      @course_area = Factory(:course_area, :event=>@race.event)
      @course = UseCaseSamples.build_course
      @fleet_race = Factory(:fleet_race, :course=>@course,
                            :course_area=>@course_area, 
                            :race=>@race, :color=>'Yellow', :status=>'Open',
                            :scheduled_time=>Time.now,
                            :start_time=>Time.now,
                            :end_time=>Time.now)
    end #setup
    subject {@fleet_race}

    context "an instance" do

      context "destroy call" do

        setup do
          @rm_course = @fleet_race.course
          @rm_spots = Spot.find(:all, :conditions=>{:course_id=>@rm_course.id})
          @fleet_race.destroy
        end

        should "remove the fleet race" do
          assert_raise ActiveRecord::RecordNotFound do
            FleetRace.find(@fleet_race)
          end
        end

        should "remove the associated course" do
          assert_raise ActiveRecord::RecordNotFound do
            Course.find(@rm_course.id)
          end
        end

        should "remove all spots associated to the course" do
          assert_raise ActiveRecord::RecordNotFound do
            @rm_spots.each do |a_spot|
              Spot.find(a_spot.id)
            end
          end
        end
        
        should "not remove the 'template' course" do
          assert Course.exists?(@course)
        end
      end #destroy call

      should "correctly assign the template course" do
        assert_not_nil @fleet_race
        assert_not_nil @fleet_race.id
        assert_not_equal @fleet_race.course_id, @course.id
        assert_equal @fleet_race.course_area_id, @course_area.id

        course = @fleet_race.course
        assert_nil course.organization_id
        assert_equal course.name, @course.name
        
        spots = @fleet_race.course.spots
        assert_equal spots.count, @course.spots.count
        assert_equal spots.*.spot_type, @course.spots.*.spot_type
        assert_equal spots.*.position, @course.spots.*.position
      end #correctly assign the course

      should "not nillify the organization_id of the template course" do
        assert_not_nil @course.organization_id
      end
      
      context "assigned a new (different) course (edit)" do

        setup do
          @old_course = @fleet_race.course
          @old_spots_ids = @old_course.spots.*.id
          @new_course = UseCaseSamples.build_course :race=>@race.organization

          @fleet_race.course = @new_course
          is_saved = @fleet_race.save!
          assert is_saved
        end #setup

        should "correctly assign the new course" do
          fleet_race = FleetRace.find(@fleet_race.id)
          course = fleet_race.course

          assert_not_nil course
          assert_not_equal course.id, @old_course.id
          assert_not_equal course.id, @new_course.id

          assert_nil course.organization_id
          assert_equal course.name, @new_course.name

          spots = fleet_race.course.spots
          assert_equal spots.count, @new_course.spots.count
          assert_equal spots.*.spot_type, @new_course.spots.*.spot_type
          assert_equal spots.*.position, @new_course.spots.*.position
        end #correctly assign the new course

        should "remove the old course" do
          assert_equal false, Course.exists?(@old_course)
          assert_equal [], Spot.find(:all, :conditions=>{:course_id=>@old_course.id})
          assert_raise ActiveRecord::RecordNotFound do
            @old_spots_ids.each do |spot_id|
              Spot.find(spot_id)
            end
          end
        end #remove the old course
      end #assigned a new (different) course (edit)

      context "getting edited and saved (triggering before_save)" do

        setup do
          @original_course = @fleet_race.course
          @original_course_spots = @original_course.spots

          @new_time = DateTime.now + 1.day
          @fleet_race.start_time = @new_time
          was_saved = @fleet_race.save!

          assert was_saved
        end

        #not assign a new clone to it
        should "preserve the original course" do
          assert Course.exists?(@original_course)

          fleet_race = FleetRace.find(@fleet_race.id)
          assert_equal fleet_race.id, @fleet_race.id
          
          assert_equal fleet_race.course.id, @original_course.id
          assert_equal fleet_race.course_id, @original_course.id
          assert_equal fleet_race.course, @original_course

          assert_equal fleet_race.course.spots, @original_course_spots
          assert_equal fleet_race.start_time, @new_time
        end
      end #getting edited and saved (triggering before_save)
    end #instance

    should "provide boats" do
      boats0 = subject.fleet_race_memberships.*.enrollment.map(&:boat)
      boats = subject.boats
      assert_equal boats0.size, boats.size
      assert_equal boats0.first, boats.first
    end
  end #A FleetRace
	
  context "A Fleet Race (today)" do
    setup {@fleet_race = UseCaseSamples.build_fleet_race }
    subject {@fleet_race}
    should "be active" do
      assert FleetRace.active.include?(subject)
    end
    should "be today" do
      assert FleetRace.today_for(subject.event).include?(subject)
    end
  end
  context "A Fleet Race (yesterday)" do
    setup {
      yesterday = Time.now.utc - 1.day
      @fleet_race = UseCaseSamples.build_fleet_race :scheduled_time=>yesterday, :end_time => yesterday
    }
    subject {@fleet_race}
    should "not be active" do
      assert ! FleetRace.active.include?(subject)
    end
    should "not be today" do
      assert ! FleetRace.today_for(subject.event).include?(subject)
    end
  end
  context "A Fleet Race (tomorrow)" do
    setup {
      tomorrow = Time.now.utc + 1.day
      @fleet_race = UseCaseSamples.build_fleet_race :scheduled_time => tomorrow
    }
    subject {@fleet_race}
    should "be active" do
      assert FleetRace.active.include?(subject)
    end
    should "not be today" do
      assert ! FleetRace.today_for(subject.event).include?(subject)
    end
  end
  
  time_zone_tests = lambda { | name |
    setup do
      @current_zone = name
      @fleet_race = UseCaseSamples.build_fleet_race :scheduled_time => DateTime.now.in_time_zone(@current_zone)
      @fleet_race.event.time_zone = @current_zone
      @fleet_race.event.save!
    end
    
    should "be today" do
      assert FleetRace.today_for(@fleet_race.event).include?(@fleet_race)
      assert @fleet_race.event.fleet_races.today_for(@fleet_race.event).include?(@fleet_race)
    end
    
    should "be today, and active" do
      assert FleetRace.today_for(@fleet_race.event).active.include?(@fleet_race)
      assert @fleet_race.event.fleet_races.today_for(@fleet_race.event).active.include?(@fleet_race)
    end
    
    should "not be today (at midnight tomorrow)" do
      @fleet_race.scheduled_time = @fleet_race.scheduled_time.in_time_zone(@current_zone).tomorrow.at_midnight
      @fleet_race.save!
      assert_equal false, FleetRace.today_for(@fleet_race.event).active.include?(@fleet_race)
      assert_equal false, @fleet_race.event.fleet_races.today_for(@fleet_race.event).active.include?(@fleet_race)      
    end
    
    should "be today, but not active" do
      @fleet_race.end_time = @fleet_race.scheduled_time.in_time_zone(@current_zone) + 1.hours
      @fleet_race.save!
      assert FleetRace.today_for(@fleet_race.event).include?(@fleet_race)
      assert @fleet_race.event.fleet_races.today_for(@fleet_race.event).include?(@fleet_race)
      assert_equal false, FleetRace.today_for(@fleet_race.event).active.include?(@fleet_race)
      assert_equal false, @fleet_race.event.fleet_races.today_for(@fleet_race.event).active.include?(@fleet_race)
    end
    
    should "be today, at 23:59:59" do
      @fleet_race.scheduled_time = @fleet_race.scheduled_time.in_time_zone(@current_zone).tomorrow.at_midnight-1.seconds
      @fleet_race.save!
      assert FleetRace.today_for(@fleet_race.event).active.include?(@fleet_race)
      assert @fleet_race.event.fleet_races.today_for(@fleet_race.event).active.include?(@fleet_race)
    end
    
    should "be today, at 00:00:00" do
      @fleet_race.scheduled_time = @fleet_race.scheduled_time.in_time_zone(@current_zone).at_beginning_of_day
      @fleet_race.save!
      assert FleetRace.today_for(@fleet_race.event).active.include?(@fleet_race)
      assert @fleet_race.event.fleet_races.today_for(@fleet_race.event).active.include?(@fleet_race)
    end
  }
    
  context "Time Zone Tests" do
    for tz in %w(Amsterdam GMT Zulu Kathmandu Mumbai Pacific/Honolulu Pacific/Kiritimati)
      context tz do time_zone_tests.bind(self).call(name) end
    end
  end

end