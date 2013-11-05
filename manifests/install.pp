class deploy::install {

  validate_string($::deploy::version)

  package{'deploy':
    ensure => $::deploy::version,
  }
}
