class deploy::config {

  validate_string($::deploy::private_key)
  validate_string($::deploy::public_key)
  validate_array($::deploy::from_ips)
  validate_array($::deploy::groups)
  validate_bool($::deploy::pg_role)
  validate_absolute_path($::deploy::cache_dir)
  validate_string($::deploy::cache_dir_group)

  user{'deploy':
    ensure     => 'present',
    groups     => $::deploy::groups,
    managehome => true,
    system     => true,
  }
  ->
  group{'deploy':
    ensure  => 'present',
    system  => true,
  }
  ->
  file {'/home/deploy':
    ensure => 'directory',
    owner  => 'deploy',
    group  => 'deploy',
    mode   => '0755',
  }
  ->
  file {'/home/deploy/.ssh':
    ensure  => 'directory',
    owner   => 'deploy',
    group   => 'deploy',
    mode    => '0755',
  }

  $common_options = [
    'command="/usr/bin/deploy"',
    'no-pty',
    'no-port-forwarding',
    'no-X11-forwarding',
  ]

  $options = empty($::deploy::from_ips) ? {
    false   => concat(
      $common_options,
      inline_template('from="<%= @from_ips.sort.join(",")%>),"')),
    default => $common_options,
  }

  if defined(Sshd_config['AuthorizedKeysFile']) {
    $target = '/etc/ssh/authorized_keys/deploy'
    $user = 'root'
    file { '/etc/ssh/authorized_keys/deploy':
      ensure => file,
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
    }
  } else {
    $target = undef
    $user = 'deploy'
  }

  ssh_authorized_key{'deploy on deploy':
    ensure  => 'present',
    user    => $user,
    type    => 'ssh-rsa',
    key     => $::deploy::public_key,
    options => $options,
    target  => $target,
    require => File['/home/deploy/.ssh'],
  }

  file{'/home/deploy/.ssh/id_rsa':
    ensure  => 'present',
    owner   => 'deploy',
    group   => 'deploy',
    mode    => '0600',
    content => $::deploy::private_key,
    require => File['/home/deploy/.ssh'],
  }

  # don't prompt for remote host key validation
  file {'/home/deploy/.ssh/config':
    ensure => 'present',
    owner  => 'deploy',
    group  => 'deploy',
    mode   => '0640',
  }->
  ssh_config {'deploy_StrictHostKeyChecking':
    key    => 'StrictHostKeyChecking',
    host   => '*',
    value  => 'no',
    target => '/home/deploy/.ssh/config'
  }

  $groups = $::deploy::groups
  $sudo_groups = inline_template('%<%= @groups.join(", %") %>')

  sudo::conf {'deploy':
    ensure  => present,
    content => "# Managed by Puppet (${name})
User_Alias DEPLOY = ${sudo_groups}
Defaults:DEPLOY !umask
DEPLOY ALL=(deploy) /usr/bin/deploy
",
  }

  file{$::deploy::cache_dir:
    ensure  => 'directory',
    owner   => 'deploy',
    group   => $::deploy::cache_dir_group,
    mode    => '2775',
  }
  if $::deploy::cache_dir != '/var/cache/deploy' {
    file{'/var/cache/deploy':
      ensure => link,
      force  => true,
      target => $::deploy::cache_dir,
    }
  }

  if $::deploy::pg_role {
    postgresql::server::role {'deploy':
      superuser => true,
    }
  }

}
