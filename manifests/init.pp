# == Class: deploy
#
class deploy(
  $private_key     = undef,
  $public_key      = undef,
  $from_ips        = [],
  $version         = 'present',
  $groups          = [],
  $pg_role         = true,
  $cache_dir       = '/var/cache/deploy',
  $cache_dir_group = 'deploy',
  $enable_sudo     = true,
) {

  validate_array($from_ips)
  validate_string($version)
  validate_array($groups)
  validate_bool($pg_role)

  class{'::deploy::install': }
  -> class{'::deploy::config': }
  -> Class['deploy']
}
