class CalendarEntriesController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => [:index]

  auto_actions_for :event, [:index, :new, :create]

  smart_form_setup

  def index_for_event
    @event = Event.find(params[:event_id])
    @has_tz = @event.time_zone != nil && @event.time_zone.strip.length > 0

    if params[:course_area_id].to_i > 0
      @course_area = @event.course_areas.find(params[:course_area_id])
    else
      @course_area = CourseArea.new
    end

    if @has_tz
      d = if @event.start_time.nil? || @event.start_time_event < Date.today then Date.today else @event.start_time_event.to_date end
    else
      d = if @event.start_time.nil? || @event.start_time < Date.today then Date.today else @event.start_time.to_date end
    end
    @year = params[:year].to_i > 0 ?  params[:year].to_i : d.year
    @woy = params[:week].to_i > 0 ? params[:week].to_i : d.cweek
    @date_start = Date.commercial(@year, @woy, 1).to_datetime
    @date_end = Date.commercial(@year, @woy, 7).to_datetime
    @prev_week = @date_start-1.week
    @next_week = @date_start+1.week

    if @has_tz
      tz_offset = @date_start.in_time_zone(@event.time_zone).utc_offset
      @date_start -= tz_offset.second
      @date_end -= tz_offset.second
    end

    conditions = {:scheduled_time=>@date_start..(@date_end+1.day)}
    calendar_entries = @event.calendar_entries.find(:all, :conditions=>conditions)
    if @course_area.id
      conditions[:course_area_id] = @course_area.id
    end
    fleet_races = @event.fleet_races.find(:all, :conditions=>conditions)
    @unscheduled_fleet_races = @event.fleet_races.find(:all, :conditions=>conditions.update({:scheduled_time=>nil}))

    if @has_tz
      @date_start += tz_offset.second
      @date_end += tz_offset.second

      @boxes = (calendar_entries+fleet_races).group_by {|e| e.scheduled_time_event.strftime('%Y%m%d%H')+'%02d'%(e.scheduled_time_event.min/15*15)}
    else
      @boxes = (calendar_entries+fleet_races).group_by {|e| e.scheduled_time.strftime('%Y%m%d%H')+'%02d'%(e.scheduled_time.min/15*15)}
    end
    @rows = Hash.new
    (0..23).each do |hour|
      (0..45).step(15) do |minute|
        rowid = '%02d'%hour+'%02d'%minute
        @rows[rowid] = [1, (hour*4+(minute/15))*20]
      end
    end

    @boxes.each do |key, values|
      rowid = key[8,4]
      @rows[rowid][0] = [@rows[rowid].first, values.length].max
    end
    additional_height = 0
    @rows.keys.sort.each do |key|
      value = @rows[key]
      value[1] += additional_height
      if (value.first > 1) then additional_height += (value.first-1)*20 end
    end

    hobo_new_for :event do |format|
      format.html 
      format.js { render :partial=>'calendar_view_entries' }
    end
  end


  def create_for_event
    hobo_create_for :event do |format|
      #format.html
      #format.js { index_for_event }
      if valid?
        respond_to do |wants|
          wants.html { redirect_after_submit(:redirect=>session['HTTP_REFERER']) }
          wants.js   { index_for_event }
        end
      else
        respond_to do |wants|
		  # errors is used by the translation helper, ht, below.
		  errors = this.errors.full_messages.join("\n")
          wants.html { re_render_form('new_for_event') }
          wants.js   { render(:status => 500,
              :text => ht( :"#{this.class.name.pluralize.underscore}.messages.create.error", :errors=>errors,:default=>["Couldn't create the #{this.class.name.titleize.downcase}.\n #{errors}"])
              )}
        end
      end
    end
  end

end
