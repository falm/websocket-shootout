require ::File.expand_path('../environment', __FILE__)
Rails.application.eager_load!

run ActionCable.server