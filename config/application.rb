require File.expand_path('../boot', __FILE__)

require 'rails/all'

Bundler.require(*Rails.groups)

module LiveVoting

  class Application < Rails::Application

    config.active_record.raise_in_transactional_callbacks = true
 		config.exceptions_app = self.routes

  end
end
