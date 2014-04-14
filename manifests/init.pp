# == Class: deploy
#
class deploy(
  $private_key,
  $public_key,
  $from_ips = [],
  $version  = 'present',
  $groups   = [],
) {

  validate_string($private_key)
  validate_string($public_key)
  validate_array($from_ips)
  validate_string($version)
  validate_array($groups)

  class{'deploy::install': } ->
  class{'deploy::config': } ->
  Class['deploy']
}
