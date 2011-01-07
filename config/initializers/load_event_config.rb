EVENT_CONFIG = YAML.load_file("#{RAILS_ROOT}/config/event_config.yml")[RAILS_ENV].with_indifferent_access
  
