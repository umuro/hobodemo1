module ActiveRecord
  class BaseWithoutTable < Base
    self.abstract_class = true
    
    def create_or_update_without_callbacks
      self.new_record? ? create_without_callbacks : update_without_callbacks
    end
    def create_without_callbacks
      @new_record = false if answer = errors.empty?
      answer
    end
    def update_without_callbacks
      @new_record = false if answer = errors.empty?
      answer
    end
    def destroy_without_callbacks
      errors.empty?
    end

    class << self
      def columns()
        @columns ||= []
      end
      
      def column(name, sql_type = nil, default = nil, null = true)
        columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
        reset_column_information
      end
      
      # Do not reset @columns
      def reset_column_information
        generated_methods.each { |name| undef_method(name) }
        @column_names = @columns_hash = @content_columns = @dynamic_methods_hash = @read_methods = nil
      end
    end
  end
end
