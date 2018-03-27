output="[1;31mError: Could not uninstall module 'tsp'
  Module 'tsp' is not installed
    You may have meant `puppet module uninstall tspy-code_deploy`
    You may have meant `puppet module uninstall tspy-module_uninstaller`"
outputerr=output.split("\n")
puts outputerr[2..100]