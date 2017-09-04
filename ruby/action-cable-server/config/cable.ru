require ::File.expand_path('../environment', __FILE__)

require 'memory_profiler'

# MemoryProfiler.report do
  Rails.application.eager_load!
  run ActionCable.server
# end.pretty_print