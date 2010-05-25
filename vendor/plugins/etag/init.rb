# Include hook code here
ActiveRecord::Base.class_eval { extend Etag::Model }
ActionController::Base.class_eval { extend Etag::Controller }
ActiveRecord::Base.class_eval { extend Etag::Sql::QueryTrap }