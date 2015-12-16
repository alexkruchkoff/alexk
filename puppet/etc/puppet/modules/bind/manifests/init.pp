class bind {
  class { '::bind::package': } ->
  class { '::bind::config': }  ->
  class { '::bind::service':}  ->
  Class['bind']
}

