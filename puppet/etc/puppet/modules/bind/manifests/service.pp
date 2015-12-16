class bind::service {
  service { "named":
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
    require    => Class["bind::config"],
  }
}

