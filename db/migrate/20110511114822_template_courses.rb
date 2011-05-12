class TemplateCourses < ActiveRecord::Migration
  def self.up
    add_column :courses, :type, :string

    add_index :courses, [:type]
  end
  
  def self.down
    remove_column :courses, :type

    remove_index :courses, :name => :index_courses_on_type rescue ActiveRecord::StatementInvalid
  end
end
