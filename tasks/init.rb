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

params = JSON.parse(STDIN.read)

def install_module(modules,version)
  if version.empty?
    stdout, stderr, status = Open3.capture3('/opt/puppetlabs/bin/puppet', 'module', 'install', modules)
  else
    stdout, stderr, status = Open3.capture3('/opt/puppetlabs/bin/puppet', 'module', 'install', modules, '--version', version)
  end
  {
    stdout: stdout.strip,
    stderr: stderr.strip,
    exit_code: status.exitstatus
  }

modules = params['modules'].split(',')

modules.each do |modules|
  results[modules] = {}

  output = install_module(modules)
  output_index = output[:stdout].index('[')
  output_eol = output[:stdout][output_index..-1]
  output_json = JSON.parse(output_eol)
  json_status = output_json[0]['staus']

  results[modules][:result] = if json_status == 'complete'
                                "Successfully deployed the #{modules} module."
                              else
                                "#{output_json[0]['error']['msg']}"
                              end

  end
end
puts results.to_json
