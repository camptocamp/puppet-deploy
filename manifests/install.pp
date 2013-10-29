class deploy::install {
  package{'deploy':
    ensure => $::deploy::version,
  }
}
