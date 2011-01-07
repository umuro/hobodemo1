def in_memory_database?
  Rails.env == "test" and
    ActiveRecord::Base.connection.class == ActiveRecord::ConnectionAdapters::SQLiteAdapter ||
      ActiveRecord::Base.connection.class == ActiveRecord::ConnectionAdapters::SQLite3Adapter and
    Rails.configuration.database_configuration['test']['database'] == ':memory:'
end

if in_memory_database?
  puts "creating sqlite in memory database"
  sch = ActiveRecord::Schema
  save, sch.verbose = sch.verbose, false
  begin
    load "#{Rails.root}/db/schema.rb"
  ensure
    sch.verbose = save
  end
end