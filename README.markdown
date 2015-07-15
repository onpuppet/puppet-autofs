[![Build Status](https://travis-ci.org/Yuav/puppet-autofs.svg?branch=master)](https://travis-ci.org/Yuav/puppet-autofs)
[![Dependency Status](https://gemnasium.com/Yuav/puppet-autofs.png)](http://gemnasium.com/Yuav/puppet-autofs)

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with autofs](#setup)
    * [What autofs affects](#what-autofs-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with autofs](#beginning-with-autofs)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Limitations - OS compatibility, etc.](#limitations)

## Overview

Installs and configures autofs which provides automount functionality. Tested with Ubuntu 12.04, Ubuntu 14.04 and CentOS 7

## Module Description

Installs and configures autofs which provides automount functionality. Tested with Ubuntu 12.04, Ubuntu 14.04 and CentOS 7

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

    class { 'autofs': 
        mounts => {
            'home' => {
                remote     => 'nfs.com:/export/home',
                mountpoint => '/home',
                options    => 'hard,rw',
            },
        }
    }
    
Using the autofs::mount directly:
    
    autofs::mount('nfs.com:/export/home','/home','hard,rw')

## Limitations

Only tested with Ubuntu 12.04, Ubuntu 14.04 and CentOS 7. Other OS'es might work, but are not tested