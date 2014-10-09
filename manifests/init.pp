# This is the rji/pam_radius_auth module for Puppet.
# Written by Roger Ignazio <rignazio at gmail dot com>
#
# Configuration:
# $pam_radius_servers, $pam_radius_secret, and $pam_radius_timeout should
# be modified for your environment. The 'redhat-lsb' package will be installed
# to determine the OS major release.
#
# Compatibility:
# This module should also handle newer (or older) EL releases, or other distros,
# with slight modification (eg. putting the pam_radius_auth config in your
# system's relevant PAM file(s)). See GitHub or the README for more information.
#
class pam_radius_auth (
  $pam_radius_servers = undef,
  $pam_radius_secret  = undef,
  $pam_radius_timeout = undef
) {

  include stdlib

  $pam_radius_servers_real  = $pam_radius_servers
  $pam_radius_secret_real   = $pam_radius_secret
  $pam_radius_timeout_real  = $pam_radius_timeout

  validate_array($pam_radius_servers_real)
  validate_re($pam_radius_secret_real, '^[~+._0-9a-zA-Z:-]+$')
  validate_re($pam_radius_timeout_real, '^[0-9]+$')

  # Distribution check
  case $::operatingsystem {
    centos, redhat: {
      # Vars that apply to all Enterprise Linux releases
      $pkg  = 'pam_radius'
      $conf = '/etc/pam_radius.conf'

      case $::operatingsystemmajrelease {
        5: {
          $supported     = true
          $pam_sshd_conf = 'pam_sshd_el5'
          $pam_sudo_conf = 'pam_sudo_el5'
        }
        6: {
          $supported     = true
          $pam_sshd_conf = 'pam_sshd_el6'
          $pam_sudo_conf = 'pam_sudo_el6'
        }
        default: {
          $supported = false
          notify { "pam_radius_auth module not supported on operating system release: ${::operatingsystemmajrelease}":}
        }
      }
    }
    ubuntu, debian: {
      # This module has been tested with Ubuntu 12.04 LTS.
      # Your experience may differ on older releases.
      $supported     = true
      $pkg           = 'libpam-radius-auth'
      $conf          = '/etc/pam_radius_auth.conf'
      $pam_sshd_conf = 'pam_sshd_deb'
      $pam_sudo_conf = 'pam_sudo_deb'
    }
    default: {
      $supported = false
      notify { "pam_radius_auth module not supported on OS ${::operatingsystem}":}
    }
  }

  # Environment checks passed, let's continue.
  if ($supported == true) {
    # Package installation
      # On Redhat/CentOS, pam_radius is in the EPEL repo
      # On Debian/Ubuntu, libpam-radius-auth is included in main
    package { $pkg:
      ensure  => present,
    }

    file { $conf:
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0600',
      content => template('pam_radius_auth/pam_radius.conf.erb'),
      require => Package[$pkg],
    }

    # Copy sshd and sudo files to /etc/pam.d
    file { '/etc/pam.d/sshd':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      source  => "puppet:///modules/pam_radius_auth/${pam_sshd_conf}",
      require => [ Package[$pkg], File[$conf] ],
    }

    file { '/etc/pam.d/sudo':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      source  => "puppet:///modules/pam_radius_auth/${pam_sudo_conf}",
      require => [ Package[$pkg], File[$conf] ],
    }
  }
}
