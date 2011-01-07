# Hobo::ModelRouter.reload_routes_on_every_request = true
Hobo::ModelRouter.reload_routes_on_every_request = ! Rails.env.production?
Hobo::Dryml.precompile_taglibs if File.basename($0) != "rake" #&& Rails.env.production?
