#!/opt/puppetlabs/puppet/bin/ruby

# Puppet Task to install a Puppet Forge module
# https://puppet.com/docs/puppet/5.3/modules_installing.html
# This can only be run against the Puppet Master.
#
# Parameters:
#   * module - The name of the Puppet Forge module to install.
#   * version - The version of the module to install.

require 'puppet'
require 'puppetclassify'
require 'open3'

Puppet.initialize_settings


unless Puppet[:server] == Puppet[:certname]
  puts 'This task can only be run against the Master (of Masters)'
  exit 1
end

def code_manager_installed?
  if File.exist?('/etc/puppetlabs/code-staging')
    true
  else
    false
  end
end

unless code_manager_installed?
  puts 'It appears that Code Manager is installed look here for more information'
  puts 'Managing environment content with a Puppetfile'
  puts 'https://puppet.com/docs/pe/2017.3/code_management/puppetfile.html#managing-environment-content-with-puppetfiles'
  puts ''
  puts '-------------------------------'
  puts '-------------------------------'
  puts '-------------------------------'
  puts "Continuing installation of #{modules} "
  exit 0
end

results = {}
params = JSON.parse(STDIN.read)
modules = params['modules']

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

# Install each module separately. The module is separated by '='
# in the console. This should be documented.
#
# Example input
# key=value
# module=version - tspy-code_deploy=1.0.2

modules.each do |mod|
  results[mod] = {}
  modlist=mod.split('=')

# modlist is the list of modules installed.
# the split is on the '='
# version is the second value version number
# if there a version is entered then install with 
# that version number
# otherwise install without a version number, which is latest.

  if modlist.length > 1
    version=modlist[1]
  else
    version=''
  end
  
  output=install_module(modlist[0],version)
  results[mod][:result] = if output[:stderr] 
                                "Successfully deployed the #{modules} module."
                              else
                                "#{output_json[0]['error']['msg']}"
                              end
end
puts results.to_json
