[![Build Status](https://travis-ci.org/onpuppet/puppet-autofs.svg?branch=master)](https://travis-ci.org/onpuppet/puppet-autofs)

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with autofs](#setup)
    * [What autofs affects](#what-autofs-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with autofs](#beginning-with-autofs)
4. [Usage - Configuration options and additional functionality](#usage)
    * [Using hiera](#using-hiera)

## Overview

Installs and configures autofs which provides automount functionality.

## Module Description

Installs and configures autofs which provides automount functionality.

## Setup

### What autofs affects

* Package autofs, and corresponding configs will be managed by Puppet - overwriting any local files

### Setup Requirements

Requires puppetlabs-stdlib and puppetlabs-concat modules

### Beginning with autofs

Basic installation:

    class { 'autofs': }

## Usage

Example usage for automounting home folders:
```puppet
class { 'autofs':
  mounts => {
    'home' => {
      remote     => 'nfs.com:/export/home',
      mountpoint => '/home',
      options    => '-hard,rw',
    },
    'net'  => {
      remote     => 'nfs:/folder',
      mountpoint => '/remote/folder',
      options    => '-soft,ro',
    },
    'misc' => {
      remote     => ':/dev/sdb1',
      mountpoint => '/misc/usb',
      options    => '-fstype=auto,rw',
    },
  }
}
```
Using the autofs::mount directly:

```puppet
autofs::mount { 'home':
  remote     => 'nfs.com:/export/home',
  mountpoint => '/home',
  options    => '-hard,rw',
}
```
Supplying a custom automount file:
```puppet
class { 'autofs':
  mount_files => {
    'home' => {
      mountpoint  => '/home',
      file_source => 'puppet:///modules/mymodule/auto.home',
    },
    'net'  => {
      mountpoint  => '/remote',
      file_source => 'puppet:///modules/mymodule/auto.net',
    }
  }
}
```
Using autofs::mountfile directly
```puppet
autofs::mountfile { 'homefile':
  mountpoint  => '/home', 
  file_source => 'puppet:///modules/mymodule/auto.home',
}
```      

To set e.g. --timeout option in auto.master, you need to manually configure the
auto.master entry using the mount_entries param like so:
```puppet
class { 'autofs':
  mount_entries => {
    '/etc/auto._misc' => { # Resource name match generated name in Mount['misc']
      mountpoint => '/misc',
      mountfile  => '/etc/auto._misc', # Matched to auto generated name in Mount['misc']
      options    => '--timeout=300',
    }
  },
  mounts => {
    'misc'      => {
      remote     => 'nfs:/export/misc/stuff',
      mountpoint => '/misc/stuff',
      options    => '--timeout=300',
    }
  }
}
```

To set the filename of the generated mapfile, set the `$mapname` parameter.
This will set the filename to `/etc/auto.${mapname}`:
```puppet
class { 'autofs':
  mount_entries => {
    '/etc/auto.glusterfs' => { # Matched to mapname for Mount['glusterfs']
      mountpoint => '/misc',
      mountfile  => '/etc/auto.glusterfs', # Matched to mapname for Mount['glusterfs']
      options    => '--timeout=300',
    }
  },
  mounts => {
    'glusterfs' => {
      mapname    => 'glusterfs',
      remote     => 'glusters:/gv0',
      mountpoint => '/mnt/gv0',
      options    => '-fstype=glusterfs',
    }
  }
}
```
### Using hiera

If you're using hiera:
```puppet
autofs::mounts:
  'misc':
    remote: 'nfs:/export/misc/stuff'
    mountpoint: '/misc/stuff'
    options: '-hard,rw'
autofs::mount_entries:
    '/etc/auto._misc':
      mountpoint: '/misc'
      mountfile: '/etc/auto._misc'
      options: '--timeout=300'
```
