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

# modlist is the list of modules installed.
# the split is on the '='
# version is the second value, version number
# if there a version is entered then install with that version number
# otherwise install without a version number, which is latest.

  if modlist.length > 1
    version=modlist[1]
  else
    version=''
  end
  
  output=install_module(modlist[0],version)
  results[mod][:result] = if output[:stdout].include? 'already installed'
                            puts "The #{modules} module is already installed."
                          case output[:stderr]
                            when /400 Bad Request/
                              puts "The #{modules} module(s) could not be found on Puppet Forge"
                              puts 'Check your spelling and try again.'
                            when /No releases are available/
                              puts "The #{modules} module(s) could not be found on Puppet Forge"
                              puts 'Check your spelling and try again.'
                            when /satisfy all dependencies/
                              puts "The #{modules} module(s) could not be installed because of"
                              puts 'dependency issues. Please install dependencies before trying again.'
                              puts 'Or you can force the installation with the --ignore-dependencies option.'
                            when /No releases matching/
                              puts "The #{modules} module(s) could not be installed because the version is"
                              puts "incorrect. Check the version and try again."
                            else
                              puts "The #{modules} module(s) could not be installed"
                          end
                        end

def code_manager_installed?
  if not File.exist?('/etc/puppetlabs/code-staging')
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
  puts ''
  puts "Continuing installation of #{modules} "
  exit 0
end
end
