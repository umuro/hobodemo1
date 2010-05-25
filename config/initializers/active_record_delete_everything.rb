#config/initializers/active_record_delete_everything.rb

module ActiveRecord
  class Base
    class << self
      def delete_everything!
        begin  
          ActiveRecord::Base.connection.rollback_db_transaction  
        rescue 
          #Intentionally suppress exception when no trasactions
        end
        klasses = ActiveRecord::Base.connection.tables.reject { |t| t == 'schema_migrations' }.collect { |t| t.classify.constantize }
        klasses.each { | k | k.delete_all }
      end
    end
  end
end