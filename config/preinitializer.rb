class Pathname  
  def empty?  
    to_s.empty?  
  end  
end  

# Fallback on doing the resolve at runtime.  
require "rubygems"  
require "bundler"  
Bundler.setup  

