class CalendarEntriesController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => [:index]

  auto_actions_for :event, [:index, :new, :create]

  def index_for_event
    @event = Event.find(params[:event_id])

    d = if @event.start_time.nil? || @event.start_time < Date.today then Date.today else @event.start_time.to_date end
    @year = params[:year].to_i > 0 ?  params[:year].to_i : d.year
    @woy = params[:week].to_i > 0 ? params[:week].to_i : d.cweek
    @date_start = Date.commercial(@year, @woy, 1)
    @date_end = Date.commercial(@year, @woy, 7)
    @prev_week = @date_start-1.week
    @next_week = @date_start+1.week

    @unscheduled_fleet_races = @event.fleet_races.find(:all, :conditions=>['scheduled_time is null'])
    conditions = ['scheduled_time between ? and ?', @date_start, @date_end+1.day] 
    calendar_entries = @event.calendar_entries.find(:all, :conditions=>conditions)
    fleet_races = @event.fleet_races.find(:all, :conditions=>conditions)
    @boxes = (calendar_entries+fleet_races).group_by {|e| e.scheduled_time.strftime('%Y%m%d%H')+'%02d'%(e.scheduled_time.min/15*15)} 
    @rows = Hash.new
    (8..23).each do |hour|
      (0..45).step(15) do |minute|
        rowid = '%02d'%hour+'%02d'%minute
        @rows[rowid] = [1, ((hour-8)*4+(minute/15))*20]
      end
    end

    # remove entries/fleets with invalid scheduled_time
    @boxes.delete_if do |key, values|
      if @rows[key[8,4]] == nil
        logger.error("ERROR! invalid scheduled_time for #{values.collect{|r| r.class.name+'#'+r.id.to_s}.join(',')}")
        true
      else
        false
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
      format.html
      format.js { index_for_event }
    end
  end

end
