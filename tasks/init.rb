#!/opt/puppetlabs/puppet/bin/ruby

# Puppet Task to install a Puppet Forge module
# https://puppet.com/docs/puppet/5.3/modules_installing.html
# This can only be run against the Puppet Master.
#
# Parameters:
#   * module - The name of the Puppet Forge module to install.
#   Example usage: modname=version >> tspy-code_deploy=1.0.2

require 'puppet'
require 'puppetclassify'
require 'open3'

Puppet.initialize_settings

results = {}
params = JSON.parse(STDIN.read)
modules = params['modules'].split(',')

unless Puppet[:server] == Puppet[:certname]
  puts 'This task can only be run against the Master (of Masters)'
  exit 1
end

def install_module(modules,version)
  if version.empty?
    stdout, stderr, status = Open3.capture3('/opt/puppetlabs/bin/puppet', 'module', 'install', '--target-dir', '/etc/puppetlabs/code/modules/', modules)
  else
    stdout, stderr, status = Open3.capture3('/opt/puppetlabs/bin/puppet', 'module', 'install', '--target-dir', '/etc/puppetlabs/code/modules/', modules, '--version', version)
  end
  {
    stdout: stdout.strip,
    stderr: stderr.strip,
    exit_code: status.exitstatus
  }
end

modules.each do |mod|
  results[mod] = {}
  modlist=mod.split('=')
  modname=modlist[0]
  output=install_module(modname,version)

  if modlist.length > 1
    version=modlist[1]
  else
    version=''
  end

  if output[:exit_code] == 0
    results[mod][:result] = if output[:stdout].include? 'already installed'
                              puts "The #{modname} module is already installed."
                            else
                              puts "The #{modname} module was installed."
                            end
  else
    results[mod][:result] = case output[:stderr]
    when /400 Bad Request/
      puts "The #{modname} module(s) could not be found on Puppet Forge"
      puts 'Check your spelling and try again.'
    when /No releases are available/
      puts "The #{modname} module(s) could not be found on Puppet Forge"
      puts 'Check your spelling and try again.'
    when /satisfy all dependencies/
      puts "The #{modname} module(s) could not be installed because of"
      puts 'dependency issues. Please install dependencies before trying again.'
      puts 'Or you can force the installation with the --ignore-dependencies option.'
    when /No releases matching/
      puts "The #{modname} module(s) could not be installed because the version is"
      puts "incorrect. Check the version and try again."
    when /is already installed/
      puts 'This module is already installed.'
      puts 'You can use the upgrade option to install a different version.'
      puts 'Or you can use the force option to re-install this module.'
    when /Unparsable version range/
      puts 'The version number is incorrect.'
      puts 'Check the version number and try again.'
    else
      puts "The #{modname} module(s) could not be installed"
    end
  end
end
