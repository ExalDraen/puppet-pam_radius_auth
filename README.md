[![Build Status](https://travis-ci.org/ExalDraen/puppet-pam_radius_auth.svg?branch=master)](https://travis-ci.org/ExalDraen/puppet-pam_radius_auth)

# pam\_radius\_auth

Configures `sshd` and `sudo` PAM modules to use RADIUS for authentication.

#### Table of Contents
<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-refresh-toc -->
**Table of Contents**

- [pam\_radius\_auth](#pamradiusauth)
    - [-](#-)
    - [Description](#description)
    - [Setup](#setup)
    - [Prerequisites:](#prerequisites)
        - [What acc_firewall affects](#what-accfirewall-affects)
    - [Usage](#usage)
    - [Limitations](#limitations)
    - [Development](#development)
    - [Release Notes](#release-notes)

<!-- markdown-toc end -->


## Description

Installs and configures `pam_radius_auth` module for PAM to allow
sshd and sudo to use RADIUS for authentication. As distributed,
this will also fallback to local authentication (using localifdown)
should the RADIUS servers be unavailable.

Although the distributed copy only supports Redhat/CentOS and
Debian/Ubuntu, this module should work, with minor modifications, on
any system that supports PAM:

1.  Add support for your distro/release in init.pp
2.  Add the following line _before_ system-auth:

```
    auth [success=done new_authtok_reqd=done ignore=ignore default=die] pam_radius_auth.so localifdown
```

## Setup

## Prerequisites:

On CentOS, the EPEL repo must be installed and enabled. Information on
the EPEL repo is available at: <http://fedoraproject.org/wiki/EPEL>

### What acc_firewall affects

* `/etc/pam.d/`

## Usage

```
class { "pam_radius_auth":
  pam_radius_servers => [ "192.168.10.80",
                          "192.168.10.90" ],
  pam_radius_secret  => "sekrit",
  pam_radius_timeout => '5',
}
```

## Limitations

Only tested on CentOS 6, 7.

## Development

See `CONTRIBUTING.md`

## Release Notes

See `CHANGELOG.md`
