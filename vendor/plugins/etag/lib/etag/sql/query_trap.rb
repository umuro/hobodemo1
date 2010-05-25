module Etag
module Sql
module QueryTrap

  module InstanceMethods
  end

  module ClassMethods
    def find_by_sql_with_etag_cache sql
      qi = etag_query_info(sql)
      Thread.current[:etag_query_info] = qi
      find_by_sql_without_etag_cache sql
    end
    def etag_query_info sql
      #CAVIAT: Cannot cache if a class has custom table name
      #select
      return nil unless sql =~ /^\s*SELECT\s+/
      rest = $'
      etag_query_info = {:sql => sql}
      ruby_var_exp = '"([a-z_][a-z0-9_]*)"'
      #select fields
      rest =~ /(.*)\s+FROM/
      fields = $1
      etag_query_info[:fields] = fields
      #select fields from table
      rest =~ Regexp.new("FROM\s+#{ruby_var_exp}(\s+|$)")
      table_name = $1
      etag_query_info[:table_name] = table_name
      klass = table_name.singularize.classify.constantize rescue nil
      return nil unless klass
      etag_query_info[:class]=klass
      rest = $'
      #joins
      join_matches = rest.scan Regexp.new("JOIN\s+#{ruby_var_exp}(\s+|$)")
      joins = join_matches.collect {|m| m[0]}
      from_matches = rest.scan Regexp.new("FROM\s+#{ruby_var_exp}(\s+|$)")
      froms = from_matches.collect {|m| m[0]}
      froms << table_name
      dependencies = (joins + froms).uniq

      etag_query_info[:dependencies] = dependencies

      them = {}
      for t in dependencies do
        c =  (t.singularize.classify.constantize) rescue nil
        return nil unless c
        them[t] = c if c
      end
      depended_classes = them.values
      return nil if dependencies.size != depended_classes.size
      class << depended_classes
        def to_json
          "[#{join(', ')}]"
        end
      end
      etag_query_info[:depended_classes] = depended_classes

      #objet query?
      sql =~ Regexp.new(%Q{"\s+WHERE(\s+|\s*[\(\s*])"#{table_name}"."id"\s*=\s*([0-9]+)})
      the_id = $2
      etag_query_info[:id] = the_id.to_i unless the_id.blank?

      etag_query_info
    end
  end

  def caches_on_etag
    has_etag
    include InstanceMethods
    extend ClassMethods
    class << self
     alias_method_chain :find_by_sql, :etag_cache
    end
  end

end
end
end

# http://pivotalrb.rubyforge.org/svn/sql_parser/trunk/lib/sql_parser.treetop