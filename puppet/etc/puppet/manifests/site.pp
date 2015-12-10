node 'ento.ak.local' {
  file { '/etc/hostname':
    content => "ento.ak.local\n",
    mode => 0644,
    owner => 'root',
    group => 'root',
  }
}

