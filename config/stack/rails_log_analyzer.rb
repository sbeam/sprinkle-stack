require File.join(File.dirname(__FILE__), '../config.rb')

# Handles manual log parsing through CRON script, or via Scout app

package :rails_log_analyzer do
  desc 'Provides log parsing tools for Hodel3000 compliant logger.'
  gem 'production_log_analyzer rails_analyzer_tools request-log-analyzer' do
    post :install, "ln -sf #{RUBY_INSTALL[:path]}/bin/pl_analyze /usr/local/bin/pl_analyze"
  end
  
  verify do
    has_gem 'production_log_analyzer'
    has_gem 'rails_analyzer_tools'
    has_gem 'request-log-analyzer'
    has_executable 'pl_analyze'
  end
  
  requires :ruby
end
