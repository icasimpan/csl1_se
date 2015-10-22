include stdlib

file { '/etc/bash.bashrc':
    ensure => present,
} ->
file_line { 'Append LANGUAGE to /etc/bash.bashrc':
    path => '/etc/bash.bashrc',
    line => 'export LANGUAGE=en_US.UTF-8',
    match => "^LANGUAGE=.*$",
} ->
file_line { 'Append LANG to /etc/bash.bashrc':
    path => '/etc/bash.bashrc',
    line => 'export LANG=en_US.UTF-8',
    match => "^LANG=.*$",
} ->
file_line { 'Append LC_ALL to /etc/bash.bashrc':
    path => '/etc/bash.bashrc',
    line => 'export LC_ALL=en_US.UTF-8',
    match => "^LC_ALL=.*$",
}->
exec { 'apply_locale1':
  command => '/usr/sbin/locale-gen en_US.UTF-8',
}->
exec { 'apply_locale2':
  command => '/usr/sbin/dpkg-reconfigure locales',
}
