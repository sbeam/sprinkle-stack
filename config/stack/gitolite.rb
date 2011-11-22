require File.join(File.dirname(__FILE__), '../config.rb')

package :gitolite do
  description 'SSH-based gatekeeper for git repositories'
  git 'git://github.com/sitaramc/gitolite.git'
  git_user 'git'

  noop do
    pre :install, "su -l -c \"ssh-keygen -f /home/#{USER_TO_ADD}/.ssh/id_rsa -P ''\" #{USER_TO_ADD}"
    pre :install, "cat /home/#{USER_TO_ADD}/.ssh/id_rsa.pub > /tmp/key.pub"
    pre :install, "chmod ugo+r /tmp/key.pub"

    pre :install, "adduser #{git_user} --disabled-password --gecos ''"

    pre :install, "/usr/bin/git clone #{git}"
    pre :install, "gitolite/src/gl-system-install > /tmp/gl-system-install.log"
    pre :install, "su -l -c \"echo '' | gl-setup /tmp/key.pub\" #{git_user} > /tmp/gl-setup.log"

    post :install, "rm -rf gitolite"
    post :install, "rm /tmp/key.pub"
  end

  verify do
    has_directory '/home/git/repositories'
  end

  requires :build_essential
  requires :git
  requires :user
end

