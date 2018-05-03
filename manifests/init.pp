# This is the pam_radius_auth module for Puppet.
# Based on the original written by Roger Ignazio <rignazio at gmail dot com>
# and modifications by Cegeka.
#
# @param pam_radius_servers Array[String] List of RADIUS servers to configure PAM for
# @param pam_radius_secret String Secret shared between radius servers and client
# @param pam_radius_timeout Integer Timeout (in seconds) for PAM RADIUS authentication.
#
class pam_radius_auth (
  Enum['present', 'absent'] $ensure                       = present,
  Array[String, 1] $pam_radius_servers                    = undef,
  Pattern[/[~+._0-9a-zA-Z:-]+/] $pam_radius_secret        = undef,
  Integer $pam_radius_timeout                             = undef,
  Enum['permissive', 'strict'] $pam_radius_enforce        = 'permissive',
  String $pam_radius_users_file                           = 'pam_admin_users.conf',
  Array[String] $pam_radius_admin_users                   = [''],
  String $pam_radius_admins_group                         = 'admins'
) {

  $pam_radius_servers_real  = $pam_radius_servers
  $pam_radius_secret_real   = $pam_radius_secret
  $pam_radius_timeout_real  = $pam_radius_timeout
  $pam_radius_enforce_real  = $pam_radius_enforce
  $pam_radius_users_file_real = $pam_radius_users_file
  $pam_radius_admins_group_real = $pam_radius_admins_group

  # Distribution check
  case $::operatingsystem {
    'RedHat','CentOS': {
      # Vars that apply to all Enterprise Linux releases
      $pkg  = 'pam_radius'
      $conf = '/etc/pam_radius.conf'

      case $::operatingsystemmajrelease {
        '5': {
          $supported     = true
          $pam_sshd_conf = 'pam_sshd_el5'
          $pam_sudo_conf = 'pam_sudo_el5'
        }
        '6': {
          $supported     = true
          $pam_sshd_conf = 'pam_sshd_el6'
          $pam_sudo_conf = 'pam_sudo_el6'
        }
        '7': {
          $supported     = true
          $pam_sshd_conf = 'pam_sshd_el7'
          $pam_sudo_conf = 'pam_sudo_el7'
        }
        default: {
          $supported = false
          notify { "pam_radius_auth module not supported on operating system release: ${::operatingsystemmajrelease}":}
        }
      }
    }
    'Ubuntu', 'Debian': {
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
      ensure  => $ensure,
    }

    file { $conf:
      ensure  => $ensure,
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
      content => template("pam_radius_auth/${pam_sshd_conf}.erb"),
      require => [ Package[$pkg], File[$conf] ],
    }

    file { '/etc/pam.d/sudo':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template("pam_radius_auth/${pam_sudo_conf}.erb"),
      require => [ Package[$pkg], File[$conf] ],
    }

    file { "/etc/${pam_radius_users_file_real}" :
      ensure  => $ensure,
      owner   => 'root',
      group   => 'root',
      mode    => '0640',
      content => template('pam_radius_auth/pam_admin_users.erb'),
      require => [ Package[$pkg], File[$conf] ],
    }

  }
}
