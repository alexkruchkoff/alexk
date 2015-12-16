class bind::install {
  package { 'bind':
    ensure => present,
  }
}
