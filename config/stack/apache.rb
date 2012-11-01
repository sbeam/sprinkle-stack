require File.join(File.dirname(__FILE__), '../config.rb')

package :apache, :provides => :webserver do
  description 'Apache2 web server.'
  apt 'apache2 apache2.2-common apache2-mpm-prefork apache2-utils libexpat1 libcurl4-openssl-dev ssl-cert' do
    post :install, 'a2enmod headers'
    post :install, 'a2enmod rewrite'
    post :install, 'a2enmod ssl'
    # Don't want default site running on host.
    post :install, 'rm /etc/apache2/sites-enabled/*'
    post :install, 'mkdir /etc/apache2/ssl'
    post :install, 'chown root:www-data /var/www'
    post :install, 'chmod 775 /var/www'
  end

  verify do
    has_executable '/usr/sbin/apache2'
  end

  requires :build_essential
  optional :apache_etag_support, :apache_deflate_support, :apache_expires_support, :passenger_config
end

package :apache2_prefork_dev do
  description 'A dependency required by some packages.'
  apt 'apache2-prefork-dev'
  verify do
    has_apt 'apache2-prefork-dev'
  end
end

package :passenger_apache, :provides => :appserver do
  description 'Phusion Passenger (mod_rails)'
  binaries = %w(passenger-config passenger-install-nginx-module passenger-install-apache2-module passenger-make-enterprisey passenger-memory-stats passenger-spawn-server passenger-status passenger-stress-test)

  gem 'passenger', :version => RUBY_INSTALL[:passenger_version] do
    binaries.each {|bin| post :install, "ln -sf #{RUBY_INSTALL[:path]}/bin/#{bin} /usr/local/bin/#{bin}"}
    post :install, 'echo -en "\n\n\n\n" | sudo passenger-install-apache2-module'
    # Restart apache to note changes
    post :install, '/etc/init.d/apache2 restart'
  end

  verify do
    has_file "#{RUBY_INSTALL[:path]}/lib/ruby/gems/1.8/gems/passenger-#{RUBY_INSTALL[:passenger_version]}/ext/apache2/mod_passenger.so"
    binaries.each {|bin| has_symlink "/usr/local/bin/#{bin}", "#{RUBY_INSTALL[:path]}/bin/#{bin}" }
  end

  requires :apache, :apache2_prefork_dev, :ruby
  optional :passenger_config
end

package :passenger_config do
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

# These "installers" are strictly optional, I believe
# that everyone should be doing this to serve sites more quickly.

# Enable ETags
package :apache_etag_support do
  apache_conf = "/etc/apache2/apache2.conf"
  config = <<EOL

# Passenger-stack-etags
FileETag MTime Size

EOL

  push_text config, apache_conf, :sudo => true do
    post :install, '/etc/init.d/apache2 restart'
  end
  verify { file_contains apache_conf, "Passenger-stack-etags"}
end

# mod_deflate, compress scripts before serving.
package :apache_deflate_support do
  deflate_conf = '/etc/apache2/conf.d/deflate.conf'
  transfer(
    File.join(File.dirname(__FILE__), 'files/apache-mod_deflate.config'),
    deflate_conf
  ) do
    post :install, 'a2enmod deflate'
    post :install, '/etc/init.d/apache2 restart'
  end
  verify { has_file deflate_conf}
end

# mod_expires, add long expiry headers to css, js and image files
package :apache_expires_support do
  apache_conf = "/etc/apache2/apache2.conf"

  config = <<EOL

# Passenger-stack-expires
<IfModule mod_expires.c>
  <FilesMatch "\.(jpg|gif|png|css|js)$">
       ExpiresActive on
       ExpiresDefault "access plus 1 year"
   </FilesMatch>
</IfModule>

EOL

  push_text config, apache_conf, :sudo => true do
    post :install, 'a2enmod expires'
    post :install, '/etc/init.d/apache2 restart'
  end

  verify { file_contains apache_conf, "Passenger-stack-expires"}
end
