#Extlib SHOULD NEVER BE LOADED!!!!
#Extlib::Inflection.rule 'serie', 'series' ,true
#begin
#  require 'extlib'
#  Extlib::Inflection.rule 'serie', 'series' ,true
#rescue
#  'Extlib gem not installed'
#end

namespace :application do
  namespace :sitemap do
    desc "Generate a Google sitemap from the models"
    task(:generate => :environment) do
      require 'big_sitemap'
      sitemap = BigSitemap.new(:url_options => {:host => 'www.regatta-rails.com'})
#      sitemap.add Part
      sitemap.generate
    end
  end
end
