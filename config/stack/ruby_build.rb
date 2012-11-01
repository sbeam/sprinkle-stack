require File.join(File.dirname(__FILE__), '../config.rb')

package :ruby_build, :provides => :ruby do
  description 'Ruby'
  source "https://github.com/sstephenson/ruby-build/tarball/v20121022" do
    custom_archive 'sstephenson-ruby-build-14dc5d6.tar.gz'

    custom_install 'sudo ./install.sh'

    post :install do
        %Q|./bin/ruby-build #{RUBY_INSTALL[:version]} /usr/local/ruby-#{RUBY_INSTALL[:version]}
            && ln -s /usr/local/ruby-#{RUBY_INSTALL[:version]} /usr/local/ruby |

    end

  end

  verify do
    has_executable_with_version(
      "/usr/local/ruby/bin/ruby", RUBY_INSTALL[:version]
    )
  end
  requires :ruby_build_dependencies

end

package :ruby_build_dependencies do
 #build_libs = %w(bison file libssl-dev libreadline5-dev libxml2 libxml2-dev libncurses5-dev
 #                libxslt1-dev readline-common openssl zlib1g zlib1g-dev)
  build_libs = %w(libssl-dev libreadline-gplv2-dev libxml2 libxml2-dev libxslt1-dev
                   readline-common openssl zlib1g zlib1g-dev make gcc autoconf libtool file curl libcurl4-openssl-dev)
  apt build_libs
  verify { build_libs.each { |pkg| has_apt pkg } }
  requires :build_essential
end
