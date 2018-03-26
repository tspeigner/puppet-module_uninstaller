stdexist = 'already installed'
stdbad = 'satisfy all dependencies'
modules = 'modulename'

  results = case stdbad
              when 'satisfy all dependencies'
                puts "couldn't satisfy #{modules} dependency"
              end
  
  
#  if "#{stdexist}" == 'already installed'
#                                puts "The #{modules} module is already installed."
#                              else
#                                if "#{stdbad}" == '400 Bad Request'
#                                  puts "The #{modules} module(s) could not be found on Puppet Forge"
#                                  puts 'Check your spelling and try again.'
#                                elsif "#{stddep}" == 'satisfy all dependencies'
#                                  puts "The #{modules} module(s) could not be installed because of"
#                                  puts 'dependency issues. Please install dependencies before trying again.'
#                                else
#                                  puts "The #{modules} module(s) could not be installed"
#                                end
#                              end
puts "#{results}"


results[mod][:result] = if output[:stdout].include? 'already installed'
  puts "The #{modules} module is already installed."
end
results[mod][:result] = case output[:stderr]
  when '400 Bad Request'
    puts "The #{modules} module(s) could not be found on Puppet Forge"
    puts 'Check your spelling and try again.'
  when 'satisfy all dependencies'
    puts "The #{modules} module(s) could not be installed because of"
    puts 'dependency issues. Please install dependencies before trying again.'
  else
    puts "The #{modules} module(s) could not be installed"
  end

