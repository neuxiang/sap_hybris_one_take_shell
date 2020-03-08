# sap_hybris_one_take_shell
A shell to manage Hybris local development environment with one take

# Get Hybris running with one take!

# Main features:
1. You can manage multiple local hybris projects with one shell, same source code and hybris package.
2. You can execute one or more Hybris ant commands by this shell once, like below:
./env_hybris.sh all --- execute "create", "link", "ant clean all", "init", "start"

Other features:
1. Prevent running next step when one ant command is run with error.
2. Include almost all hybris command in this shell and can be run with several commands together.
e.g You can run clean, initialize, update hybris command before server start command with one this shell command.
3. Add statistic of  start and end time for every ant command.



############################ Guide ############################
Steps to work:

     1. Update value "code_path", "hybris_path", etc in ./hybris_config.properties file with your local absolute path
     2. Copy this shell and hybris_config.properties to your hybris project newly Created folder, or Update "dev_project_path" with your local absolute path
     3. Run commond below and choose development pattern to set up a local Hybris dev folder in "dev_project_path":
     /Users/.../hybris_1905_mac

       ./env_hybris.sh create

Then you can execute following commond:

       ./env_hybris.sh create --- Create development hybris project with Hybris package and your code and config
       ./env_hybris.sh link --- Link custom folder and config file (local.properties and localextensions.xml)
       ./env_hybris.sh clean --- ant clean
       ./env_hybris.sh build --- ant all. -c "ant clean" and "ant all"
       ./env_hybris.sh update --- ant updatesystem
       ./env_hybris.sh init --- ant initialize
       ./env_hybris.sh start --- start server. -d "debug", -c "ant clean", -b "ant all", -h without console outprint,
       -i "ant initialize", -u "ant updatesystem"

   *   ./env_hybris.sh all --- execute "create", "link", "ant clean all", "init", "start"
       ./env_hybris.sh stop --- stop server
       ./env_hybris.sh help --- help
