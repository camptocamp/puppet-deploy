# == Class: deploy
#
class deploy(
  $private_key,
  $public_key,
  $version = 'present',
  $groups  = undef,
) {
  class{'deploy::install': } ->
  class{'deploy::config': } ->
  Class['deploy']
}
