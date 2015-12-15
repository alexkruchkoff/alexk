class bind {
  package { 'bind':
    ensure => present,
  }

  file { '/etc/named.conf':
    owner   => 'root',
    group   => 'named',
    mode    => '0640',
    source  => 'puppet:///modules/bind/etc/named.conf',
  }

  file { '/var/named/ak.local':
    owner   => 'root',
    group   => 'named',
    mode    => '0640',
    source  => 'puppet:///modules/bind/var/named/ak.local',
  }

  file { '/var/named/2.168.192-in-addr.arpa':
    owner   => 'root',
    group   => 'named',
    mode    => '0640',
    source  => 'puppet:///modules/bind/var/named/2.168.192-in-addr.arpa',
  }
}

