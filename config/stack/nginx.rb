require File.join(File.dirname(__FILE__), '../config.rb')

package :nginx, :provides => :webserver do
  description 'nginx web server.'
  apt 'nginx libexpat1 libcurl4-openssl-dev ssl-cert' do
    # Don't want default site running on host.
    post :install, 'rm /etc/nginx/sites-enabled/*'
    post :install, 'mkdir /etc/nginx/ssl'
  end

  verify do
    has_executable '/usr/sbin/nginx'
  end
  optional :nginx_config
end

package :nginx_config do
  site_conf = "/etc/nginx/sites-available/#{VHOST[:site_name]}"

  # Create the passenger conf file
  transfer(
    File.join(File.dirname(__FILE__), 'files/nginx-thin-proxy.config'),
    site_conf,
    :render => true
  ) do
    post :install, '/etc/init.d/nginx restart'
  end
end

