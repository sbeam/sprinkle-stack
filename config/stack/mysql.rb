require File.join(File.dirname(__FILE__), '../config.rb')

package :mysql_server, :provides => :database_server do
  description 'MySQL Database Server / Client'

  # Debian has a line "!includedir /etc/mysql/conf.d/" in my.cnf
  mysql_config = '/etc/mysql/conf.d/tuning.cnf'

  apt %w( mysql-server mysql-client libmysqlclient-dev )

  transfer(
    File.join(File.dirname(__FILE__), 'files/mysql.config'),
    mysql_config,
    :render => true
  ) do
    post :install, 'restart mysql'
  end

  verify do
    has_executable 'mysqld'
    has_executable 'mysql'
    has_process 'mysqld'
  end
end


package :mysql_client, :provides => :database_client do
  description "MySQL Database Client"
  apt %w( mysql-client libmysqlclient-dev )

  verify do
    has_apt 'mysql-client'
    has_apt 'libmysqlclient-dev'
    has_executable 'mysql'
  end

  optional :mysql_driver
end

package :mysql_driver, :provides => :ruby_database_driver do
  description 'Ruby MySQL database driver'
  gem 'mysql2'

  verify do
    has_gem 'mysql2'
  end

  requires :ruby
end
