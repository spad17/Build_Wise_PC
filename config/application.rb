require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module BuildWisePc
  class Application < Rails::Application
    config.load_defaults 8.1
    config.i18n.default_locale = :ru
    config.autoload_lib(ignore: %w[assets tasks])
  end
end
