class Site < ActiveRecord::BaseWithoutTable
  column :id, :integer

  hobo_model
  has_etag

  def name
    'Sitenin Tepesi'
  end

  #---- updated_at ----#
  class << self
    def updated_at
      touch unless File.exist?(file_to_touch)
      Time.at File.mtime(file_to_touch)
    end

    def touch
      FileUtils.touch file_to_touch
    end

    def file_to_touch
      File.join(RAILS_ROOT, 'tmp', "site_update_#{Rails.env}.txt")
    end
  end
  #---- AR Imitation ----#
  def updated_at
    self.class.updated_at
  end

  class << self
    def current
      unless @current
        @current = self.new
        @current.id = 1
      end
      @current
    end

    def find id, options={}
      current
    end
  end

end