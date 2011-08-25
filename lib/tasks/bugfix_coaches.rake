namespace :bugfix do
  namespace :coach do
    desc 'Coaches should have operation: Default in RegistrationRole'
    task :fix_operation => :environment do
      rls=RegistrationRole.name_is('Coach')
      rls.each do |r|
	r.operation = RegistrationRole::OperationType::DEFAULT
	ActiveRecord::Base.transaction do
	  r.save!

	  r.enrollments.each do |enr|
	    reg = Registration.new enr.attributes.delete_if {|k,v| %w{insured paid country_id date_measured crew_id boat_id measured}.include? k }
	    reg.state = enr.state
	    reg.save!
	    enr.destroy
	    puts reg.to_json
	  end
	end
      end
    end
  end
end