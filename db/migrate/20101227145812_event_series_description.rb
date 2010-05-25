class EventSeriesDescription < ActiveRecord::Migration
  def self.up
    add_column :events, :place, :string

    add_column :event_series, :description, :text
  end

  def self.down
    remove_column :events, :place

    remove_column :event_series, :description
  end
end
