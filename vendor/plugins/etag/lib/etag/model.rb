module Etag
module Model
  module InstanceMethods
    def etag
      answer = {:klass => self.class.name,
        :id => id,
        :mtime => updated_at.utc.tv_sec}
      class << answer
        include EtagHash
      end
      answer
    end
  end

  module EtagHash
    def to_s
      values.to_json.gsub(',',':').gsub(/\"|\[|\{|\}|\]/, '')
    end
  end

  module ClassMethods
    def etag_for id
      self.find(id).etag
    end
  end

  def has_etag
    include InstanceMethods
    extend ClassMethods
  end

end
end