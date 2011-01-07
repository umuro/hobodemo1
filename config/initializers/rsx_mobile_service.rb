config = YAML::load(File.open("#{Rails.root}/config/rsx_mobile_service.yml"))[Rails.env]
$RSX_MOBILE_SERVICE_REMOTE_URL = config['url']
$RSX_MOBILE_SERVICE_REMOTE_TTL = config['ttl'].to_i
