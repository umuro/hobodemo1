require 'factory_girl'

Factory.define :event_folder do |f|

  class << f
    def default_organization
      @default_organization = Mill.unless_produced?(:organization, @default_organization)#Factory(:organization)
    end
  end

  f.sequence(:name) {|n| "Event Folder #{n}"}
  f.organization { f.default_organization }

end