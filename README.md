# userportal

#### Table of Contents

1. [Overview](#overview)
2. [Usage - Configuration options and additional functionality](#usage)

## Overview

This module setups the perlbrew environment for, and installs the NOAO SDM user
portal.  This is an internal application and this module is useful only, at
best, as a reference without access to SDM's private git repositories.

## Usage

### install perl+perlmods only

```puppet
class { 'userportal':
  perlmods_git => 'git@example.org:foo/perlmods.git',
  portal_git   => 'foo', # required even though not used
  perlenv_only => true,
}
```

### install complete user portal

```puppet
class { 'userportal':
  perlmods_git => 'git@example.org:foo/perlmods.git',
  portal_git   => 'git@example.org:foo/portal.git',
}
```
