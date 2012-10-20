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
  # TODO contains SSL settings, allow optional non-SSL version
  nginx_conf = "/etc/nginx/nginx.conf"
  nginx_errors_conf = "/etc/nginx/nginx_errors.conf"
  site_conf = "/etc/nginx/sites-available/#{VHOST[:site_name]}"

  transfer(
    File.join(File.dirname(__FILE__), 'files/nginx.conf'),
    nginx_conf
  )
  transfer(
    File.join(File.dirname(__FILE__), 'files/nginx_errors.conf'),
    nginx_errors_conf
  )

  transfer(
    File.join(File.dirname(__FILE__), 'files/nginx-thin-proxy.config'),
    site_conf,
    :render => true
  ) do
    post :install, '/etc/init.d/nginx restart'
  end

end

