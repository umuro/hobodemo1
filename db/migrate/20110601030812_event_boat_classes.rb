class EventBoatClasses < ActiveRecord::Migration
  def self.up
    create_table :event_boat_classes do |t|
      t.integer :event_id, :null => false
      t.integer :boat_class_id, :null => false
    end
    add_index :event_boat_classes, [:event_id]
    add_index :event_boat_classes, [:boat_class_id]
  end

  def self.down
    drop_table :event_boat_classes
  end
end
