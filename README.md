
# module_installer

#### Table of Contents

1. [Description](#description)
2. [Usage - Configuration options and additional functionality](#usage)
3. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Description

This module allows you to install Puppet Modules directly from the Puppet Forge.

## Usage

Install the Task > Go to Tasks > Select module_installer > Enter <modulename> or <modulename=version>. If you only specify the 'modulename' the task will install the latest version, otherwise you can specify the version with the 'modulename=version' format.

## Reference

[How to install modules from Puppet Forge](https://puppet.com/docs/puppet/5.3/modules_installing.html#install-modules-from-the-puppet-forge)

## Limitations

This task will only run on a Puppet Master.

## Development

Fork it, update it, change it, or just provide feedback.