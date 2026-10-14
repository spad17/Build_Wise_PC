require_relative "../application"

Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true
  config.require_master_key = false
  config.force_ssl = ENV.fetch("FORCE_SSL", "false") == "true"
  config.active_support.report_deprecations = false
end
