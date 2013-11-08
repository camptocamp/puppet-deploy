class deploy::config {

  validate_string($::deploy::private_key)
  validate_string($::deploy::public_key)
  validate_array($::deploy::from_ips)
  validate_string($::deploy::group)
  validate_array($::deploy::groups)

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

  ssh_authorized_key{'deploy on deploy':
    ensure  => 'present',
    user    => 'deploy',
    type    => 'ssh-rsa',
    key     => $::deploy::public_key,
    options => $options,
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
    ensure  => 'present',
    owner   => 'deploy',
    group   => 'deploy',
    content => "StrictHostKeyChecking no\n",
    require => File['/home/deploy/.ssh'],
  }

  file{'/etc/sudoers.d/deploy':
    ensure  => 'file',
    mode    => '0440',
    content => inline_template("# Managed by Puppet (${name})
User_Alias DEPLOY = %<%= @group %><% if !@groups.empty? -%>, %<%= @groups.join(', %')  %><% end %>
Defaults:DEPLOY !umask
DEPLOY ALL=(deploy) /usr/bin/deploy
"),
  }

  file{'/var/cache/deploy':
    ensure  => 'directory',
    owner   => 'deploy',
    group   => $::deploy::group,
    mode    => '2775',
    require => [User['deploy'], Group[$::deploy::group]],
  }

}
