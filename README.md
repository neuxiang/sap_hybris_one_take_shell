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

Updated features:
[2020-03-15]v1.1
1. Add -c argument for commands create, link and all. It means you can copy everthing to your new project, not link.
2. Add -l argument for command create. It means you need to add -l to get command link run after command create.
3. Add open command. You can open created project in finder.
4. Add variable HYBRIS_HOME_DIR, INITIAL_ADMIN, ANT_HOME setting.


############################ Guide ############################
Steps to work:

     1. Update value "code_path", "hybris_path", etc in ./hybris_config.properties file with your local absolute path
     2. Copy this shell and hybris_config.properties to your hybris project newly Created folder, or Update "dev_project_path" with your local absolute path
     3. Run commond below and choose development pattern to set up a local Hybris dev folder in "dev_project_path":
     /Users/.../hybris_1905_mac

       ./env_hybris.sh create

Then you can execute following Commands:

       ./env_hybris.sh create --- Create development hybris project with Hybris package and your code and config. -c means copy command (cp), -l run [./env_hybris.sh link ]
       ./env_hybris.sh link --- Link(ln) custom folder and config file (local.properties and localextensions.xml), -c means copy command (cp)
       ./env_hybris.sh clean --- ant clean
       ./env_hybris.sh build --- ant all. -c "ant clean" and "ant all"
       ./env_hybris.sh update --- ant updatesystem
       ./env_hybris.sh init --- ant initialize
       ./env_hybris.sh start --- start server. -d "debug", -c "ant clean", -b "ant all", -h without console outprint,
       -i "ant initialize", -u "ant updatesystem"

   *   ./env_hybris.sh all --- execute "create", "link", "ant clean all", "init", "start". -c means copy command (cp)
       ./env_hybris.sh stop --- stop server
       ./env_hybris.sh open --- open the created project folder in Finder
       ./env_hybris.sh help --- help
