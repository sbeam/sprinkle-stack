require File.join(File.dirname(__FILE__), '../config.rb')

package :ruby_build, :provides => :ruby do
  description 'Ruby'
  source "https://github.com/sstephenson/ruby-build/tarball/master" do

    custom_install 'sudo ./install.sh'

    post :install do
        "./ruby-build #{RUBY_INSTALL[:version]} /usr/local/ruby-#{RUBY_INSTALL[:version]}"
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
  build_libs = %w(bison file libssl-dev libreadline5-dev libxml2 libxml2-dev libncurses5-dev
                  libxslt1-dev readline-common openssl zlib1g zlib1g-dev)
  apt build_libs
  verify { build_libs.each { |pkg| has_apt pkg } }
  requires :build_essential
end
