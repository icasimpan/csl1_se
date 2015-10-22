# vagrant/puppet/modules/nginx/manifests/init.pp
class nginx {
  exec { 'apt-get update':
    path => '/usr/bin',
    timeout => '0',
  }
  # make sure default htmldoc for nginx is present
  file { '/var/www':
    ensure => 'directory',
  }->

  # Install the nginx package. This relies on apt-get update
  package { 'nginx':
    ensure => 'present',
    require => Exec['apt-get update'],
  }

  # Make sure that the nginx service is running
  service { 'nginx':
    ensure => running,
    require => Package['nginx'],
  }

  # Add a vhost template
  file { 'vagrant-nginx':
    path => '/etc/nginx/sites-available/127.0.0.1',
    ensure => file,
    require => Package['nginx'],
    source => 'puppet:///modules/nginx/127.0.0.1',
  }

  # Add upstream config
  file { 'vagrant-nginx-upstream':
    path => '/etc/nginx/conf.d/upstream.conf',
    ensure => file,
    require => Package['nginx'],
    source => 'puppet:///modules/nginx/upstream',
  }

  # Disable the default nginx vhost
  file { 'default-nginx-disable':
    path => '/etc/nginx/sites-enabled/default',
    ensure => absent,
    require => Package['nginx'],
  }

  # Symlink our vhost in sites-enabled to enable it
  file { 'vagrant-nginx-enable':
    path => '/etc/nginx/sites-enabled/127.0.0.1',
    target => '/etc/nginx/sites-available/127.0.0.1',
    ensure => link,
    notify => Service['nginx'],
    require => [
      File['vagrant-nginx'],
      File['default-nginx-disable'],
    ],
  }
}
