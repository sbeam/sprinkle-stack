require File.join(File.dirname(__FILE__), '../config.rb')

package :ruby do
  description 'Ruby'
  source "https://github.com/sstephenson/ruby-build/tarball/master" do

    custom_install 'sudo ./install.sh'

    post :install do
        run "cd /usr/local"
        run "ruby-build 1.9.3-p194 /usr/local/ruby-1.9.3-194"
    end
    post :install, "gem pristine --all"
  end

  verify do
    has_executable_with_version(
      "#{REE_PATH}/bin/ruby", "Ruby Enterprise Edition 2011.03"
    )
  end

end

package :build_dependencies do
  build_libs = %w(libssl-dev libreadline5-dev libxml2 libxml2-dev
                  libxslt1-dev readline-common openssl zlib1g zlib1g-dev)
  apt build_libs
  verify { build_libs.each { |pkg| has_apt pkg } }
  requires :build_essential
end
