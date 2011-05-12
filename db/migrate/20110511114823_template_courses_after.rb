class TemplateCoursesAfter < ActiveRecord::Migration
  def self.up
    courses = Course.all :conditions => ["organization_id > 0"]
    courses.each {|c|
      c.type = "TemplateCourse";
      c.save!
      puts "-- migrated courses record #{c.id}";
    }
  end
  
  def self.down
  end
end
