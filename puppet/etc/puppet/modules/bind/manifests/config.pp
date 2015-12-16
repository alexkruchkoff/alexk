class bind::config {
  file { '/etc/named.conf':
    owner   => 'root',
    group   => 'named',
    mode    => '0640',
    source  => 'puppet:///modules/bind/etc/named.conf',
    require => Class["bind::package"],
    notify  => Class["bind::service"],
  }

  file { '/var/named/ak.local':
    owner   => 'root',
    group   => 'named',
    mode    => '0640',
    source  => 'puppet:///modules/bind/var/named/ak.local',
    require => Class["bind::package"],
    notify  => Class["bind::service"],
  }

  file { '/var/named/2.168.192-in-addr.arpa':
    owner   => 'root',
    group   => 'named',
    mode    => '0640',
    source  => 'puppet:///modules/bind/var/named/2.168.192-in-addr.arpa',
    require => Class["bind::package"],
    notify  => Class["bind::service"],
  }
}

