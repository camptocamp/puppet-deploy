class deploy::config {
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
  file {'/home/deploy/.ssh':
    ensure  => 'directory',
    owner   => 'deploy',
    group   => 'deploy',
    mode    => '0755',
  }

  ssh_authorized_key{'deploy on deploy':
    ensure  => 'present',
    user    => 'deploy',
    type    => 'ssh-rsa',
    key     => $::deploy::public_key,
    options => [
      'command="/usr/bin/deploy"',
      'no-pty',
      'no-port-forwarding',
      'no-X11-forwarding',
    ],
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

  file{'/etc/sudoers.d/deploy':
    ensure  => 'file',
    mode    => '0440',
    content => inline_template("# Managed by Puppet (${name})
User_Alias DEPLOY = %deploy<% if @groups -%>, %<%= @groups.to_a.join(', %')  %><% end %>
Defaults:DEPLOY !umask
DEPLOY ALL=(deploy) /usr/bin/deploy
"),
  }

}
