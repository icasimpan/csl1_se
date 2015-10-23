class ruby {
  include stdlib ## needed for 'file_line'

  ## dependencies in ruby
  Package { ensure => "installed" }

  $ruby_deps_list = [
                        'ImageMagick',
                        'libxml2',
                        'g++',
                        'make',
                        'libgmp-dev',
                        'libyaml-dev',
                        'libsqlite3-dev',
                        'sqlite3',
                        'libxml2-dev',
                        'libxslt-dev',
                        'autoconf',
                        'libc6-dev',
                        'ncurses-dev',
                        'automake',
                        'libtool',
                        'bison',
                        'subversion',
                        'pkg-config',
                        'curl',
                        'build-essential',
                        'libcurl4-openssl-dev',
                        'apache2-prefork-dev',
                        'libapr1-dev',
                        'libaprutil1-dev',
                        'libx11-dev',
                        'libffi-dev',
                        'tcl-dev',
                        'tk-dev',
                        'openssl',
                        'libreadline6',
                        'libreadline6-dev',
                        'zlib1g',
                        'zlib1g-dev',
                        'libssl-dev',
            ]
  package { $ruby_deps_list: }->
  ## added locale settings 
  exec { 'append_etc_bash.bashrc':
    command => '/usr/bin/sudo /usr/bin/puppet apply /vagrant/puppet/modules/ruby/_workaround/append__etc_bash.bashrc  --modulepath=/vagrant/puppet/modules',
  }->
  ## download
  exec { 'get_ruby223_source':
    command => "/usr/bin/sudo /bin/su vagrant -c '/usr/bin/wget http://ftp.ruby-lang.org/pub/ruby/2.2/ruby-2.2.3.tar.gz'",
    cwd     => '/home/vagrant',
    creates => '/home/vagrant/ruby-2.2.3.tar.gz',
    timeout => '0',
  }->
  ## unpack
  exec { 'untar_ruby223':
    command => "/usr/bin/sudo /bin/su vagrant -c '/bin/tar -xzvf /home/vagrant/ruby-2.2.3.tar.gz'",
    cwd     => '/home/vagrant',
    creates => '/home/vagrant/ruby-2.2.3/CONTRIBUTING.md',
  }->
  ## cd; ./configure --disable-install-rdoc
  exec { 'configure_ruby223':
    command => "/usr/bin/sudo /bin/su vagrant -c '/home/vagrant/ruby-2.2.3/configure --disable-install-rdoc'",
    cwd     => '/home/vagrant/ruby-2.2.3',
    creates => '/home/vagrant/ruby-2.2.3/Makefile',
  }->
  ## make
  exec { 'make_ruby223':
    command => "/usr/bin/sudo /bin/su vagrant -c '/usr/bin/make -f /home/vagrant/ruby-2.2.3/Makefile'",
    cwd     => '/home/vagrant/ruby-2.2.3',
  }->
  ## sudo make install
  exec { 'sudo_make_install':
    command => "/usr/bin/sudo /bin/su vagrant -c '/usr/bin/sudo /usr/bin/make install'",
    cwd     => '/home/vagrant/ruby-2.2.3',
    creates => '/usr/local/bin/ruby',
  }->

  ## -----------------------------
  ## install 'gem install bundler'
  ## -----------------------------
  exec { 'temp_tweak_permission_for_gem01':
    command => '/usr/bin/sudo /bin/chmod o+w -R /usr/local/lib/ruby/gems/2.2.0/',
  }->
  exec { 'temp_tweak_permission_for_gem02':
    command => '/usr/bin/sudo /bin/chmod o+w /usr/local/bin',
  }->
  exec { 'gem_install_bundler':
    command => "/usr/bin/sudo /bin/su vagrant -c '/usr/local/bin/gem install bundler'",
  }->

  ## -----------------------------
  ## install rails
  ## -----------------------------
  exec { 'gem_install_rails':
    command => "/usr/bin/sudo /bin/su vagrant -c '/usr/local/bin/gem install rails -v 4.2.4'",
    timeout => '0',
  }->
  ## ------------------------------
  ## install execjs & nodejs
  ## ------------------------------
  exec { 'install_execjs':
    command => "/usr/bin/sudo /bin/su vagrant -c '/usr/local/bin/gem install execjs'",
    timeout => '0',
  } ->
  exec { 'add_nodejs_aptrepo':
    command => "/usr/bin/sudo /usr/bin/add-apt-repository ppa:chris-lea/node.js",
  }->
  package { 'nodejs':
    ensure => 'present',
  }->

  ## -----------------------------
  ## create template ruby app
  ## -----------------------------
  exec { 'create_template_rails_app':
    command => "/usr/bin/sudo /bin/su vagrant -c '/usr/local/bin/rails new patient_card'",
    cwd     => '/home/vagrant',
    creates => '/home/vagrant/patient_card/README.rdoc',
    timeout => '0',
  }->
  exec { 'move_template_app_to_opt':
    command => "/usr/bin/sudo /bin/mv /home/vagrant/patient_card /opt",
    timeout => '0',
  }->
  ## use unicorn instead of default webrick to serve http via port 3000
  exec { 'copy_unicorn_config':
    command => "/bin/cp /vagrant/puppet/modules/ruby/files/unicorn.rb /opt/patient_card/config",
  }->

  ## ------------------------------
  ## create upstart config
  ## ------------------------------ 
  exec {'set_basic_upstart_config':
    command => "/usr/bin/sudo /bin/cp /vagrant/puppet/modules/ruby/files/patient_card.conf /etc/init/",
  }->
  exec {'chmod_app_upstart_config':
    command => "/usr/bin/sudo /bin/chmod ugo-x /etc/init/patient_card.conf",
  }->
  ## make sure app is really started
  exec {'upstart_start':
    command => "/usr/bin/sudo /sbin/start patient_card",
  }->
 
  ### ------------------------------
  ### close permission 
  ### ------------------------------

  ### now, do some permission clean-ups
  exec { 'permission_close_01':
     command => '/usr/bin/sudo /bin/chmod o-w -R /usr/local/lib/ruby/gems/2.2.0/',
  }->
  exec { 'permission_close_02':
     command => '/usr/bin/sudo /bin/chmod o-w /usr/local/bin',
  }
}
