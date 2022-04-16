# Load Intersys Cache properties for all models only for script/server
# if $0 == 'script/server'
#   IntersysPreloader.load_models!
# end
#
# if defined?(PhusionPassenger)
#   PhusionPassenger.on_event(:starting_worker_process) do |forked|
#     IntersysPreloader.load_models! if forked # we are in smart spawning mode
#   end
# end
