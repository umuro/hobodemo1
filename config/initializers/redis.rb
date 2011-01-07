Dir[File.join(Rails.root, 'app', 'jobs', '*.rb')].each { |file| require file }

redis = if ENV["REDISTOGO_URL"]
          uri = URI.parse(ENV["REDISTOGO_URL"])
          Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
        else
          config = YAML::load(File.open("#{Rails.root}/config/redis.yml"))[Rails.env]
          Redis.new(:host => config['host'], :port => config['port'])
        end

Redis::Classy.db = redis
Resque.redis = redis

