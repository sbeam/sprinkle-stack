require File.join(File.dirname(__FILE__), '../config.rb')

package :passenger, :provides => :appserver do
  description 'Passenger gem server.'
  description 'Phusion Passenger (mod_rails)'

  binaries = %w(passenger-config passenger-install-nginx-module passenger-install-apache2-module passenger-make-enterprisey passenger-memory-stats passenger-spawn-server passenger-status passenger-stress-test)

# gem 'passenger', :version => RUBY_INSTALL[:passenger_version] do
#   binaries.each {|bin| post :install, "ln -sf #{RUBY_INSTALL[:path]}/bin/#{bin} /usr/local/bin/#{bin}"}
#   post :install, 'echo -en "\n\n\n\n" | sudo passenger-install-nginx-module'
#   post :install, '/etc/init.d/nginx restart'
# end
  source "https://github.com/FooBarWidget/passenger/tarball/release-3.0.17" do
      custom_archive 'FooBarWidget-passenger-9c4cacd430.tar.gz'

      # TODO add --with-http_stub_status_module
      custom_install 'sudo ./bin/passenger-install-nginx-module'
  end

  verify do
    binaries.each {|bin| has_symlink "/usr/local/bin/#{bin}", "#{RUBY_INSTALL[:path]}/bin/#{bin}" }
  end

  requires :nginx, :ruby
end

package :apache_passenger_config do
  passenger_conf = '/etc/apache2/mods-enabled/passenger.conf'

  # Create the passenger conf file
  transfer(
    File.join(File.dirname(__FILE__), 'files/apache-passenger.config'),
    passenger_conf,
    :render => true
  ) do
    post :install, '/etc/init.d/apache2 restart'
  end

  verify { file_contains passenger_conf, RUBY_INSTALL[:passenger_version] }
end

