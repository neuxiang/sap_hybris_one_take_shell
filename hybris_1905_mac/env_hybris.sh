# Copyright 2020-2029 the original author or authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# Author: Cui Xiang
# Email: neuxiang@126.com
# WeChat: neuxiang

# Date: 2020-03-08
# Version: 1.1


shell_config_file_path=./hybris_config.properties

source ${shell_config_file_path}

#------------------------------------------------------------------------------#
# The absolute path to work with both hybris and your code, usually create 
# a new folder. "." can work in this shell folder.
 
 dev_project_path=${dev_project_path}

# The folder name in your source code (used in Hybris bin/custom/), 
# it would be linked to hyris hybris project under hybris/bin/custom folder. It's in your source code project folder.
 custom_code_folder_name=${custom_source_code_folder_name}

# The folder name in your source code used for Hybris config, 
# * Note: Have to include your local.properties and localextensions.xml under this folder
# it would be linked to hyris project as hybris/config folder. It's in your source code project folder.
 config_file_folder_name=${config_source_file_folder_name}

# The absolute path of your source code project
 code_path=${code_path}

# The absolute path of hbyris package
 hybris_path=${hybris_path}

# Config file to initialize
# init_config_json_file=init_config.json

# Config file to update
# update_config_json_file=update_config.json

# The absolute path of source code for hybris folder bin/custom
custom_code_path=$code_path/$custom_code_folder_name

# The absolute path of config files for hybris folder config
config_code_path=$code_path/$config_file_folder_name
#------------------------------------------------------------------------------#
#################################################################################
#################  Set environment variables   ##################################
export HYBRIS_HOME_DIR=${dev_project_path}
export ANT_HOME=${HYBRIS_HOME_DIR}/hybris/bin/platform/apache-ant 
# export PATH=${PATH}:${ANT_HOME}/bin
export INITIAL_ADMIN=${pass_word}

echo export HYBRIS_HOME_DIR=${dev_project_path}
echo export ANT_HOME=${HYBRIS_HOME_DIR}/hybris/bin/platform/apache-ant
echo export INITIAL_ADMIN=${pass_word}
########### DON'T CHANGE FOLLOWING CODE! ###########

if [ "${dev_project_path}" = "." ]
then
     dev_project_path=$(cd `dirname $0`; pwd)
fi

config_json_path=${dev_project_path}/${config_json}

echo
echo "------------------------- Current environment path (Hybris 1905)-----------------------------------------------"
echo
echo "    "NEW HYBRIS PROJECT PATH: ${dev_project_path}
echo "    "HYBRIS PACKAGE PATH: ${hybris_path}
echo "    "SOURCE CODE PATH: ${code_path}
echo "    "SOURCE CUSTOM CODE PATH: ${custom_code_path}
echo "    "SOURCE CONFIG FILE PATH: ${config_code_path}
echo
echo "    "platform PATH: ${dev_project_path}/hybris/bin/platform


echo 
echo "==============================================================================================================="
echo

if [ "$1" = "help" ] || [ -z "$1" ]
then
echo
echo "############################ Guide #######################################################"
echo Steps to work:
echo 
echo "    " 1. Update value \"code_path\", \"hybris_path\", etc in ${shell_config_file_path} file with your local absolute path
echo "    " 2. Copy this shell and hybris_config.properties to your hybris project newly Created folder, or Update \"dev_project_path\" with your local absolute path
echo "    " 3. Run command below and choose development pattern to set up a local Hybris dev folder in \"dev_project_path\": 
echo "    " ${dev_project_path}
echo
echo "      " ./env_hybris.sh create
echo

echo "    " Then you can execute following Commands:
echo
echo "      " "./env_hybris.sh create --- Create development hybris project with Hybris package and your code and config. -c means copy command (cp), -l run [./env_hybris.sh link ]"
echo "      " "./env_hybris.sh link --- Link(ln) custom folder and config file (local.properties and localextensions.xml), -c means copy command (cp)"
echo "      " "./env_hybris.sh clean --- ant clean"
echo "      " "./env_hybris.sh build --- ant all. -c \"ant clean\" and \"ant all\""
echo "      " "./env_hybris.sh update --- ant updatesystem"
echo "      " "./env_hybris.sh init --- ant initialize"
echo "      " "./env_hybris.sh start --- start server. -d \"debug\", -c \"ant clean\", -b \"ant all\", -h without console outprint,"
echo "      " "-i \"ant initialize\", -u \"ant updatesystem\""
echo
echo "   *  " "./env_hybris.sh all --- execute \"create\", \"link\", \"ant clean all\", \"init\", \"start\". -c means copy command (cp)"
echo "      " "./env_hybris.sh stop --- stop server"
echo "      " "./env_hybris.sh open --- open the created project folder in Finder"
echo "      " "./env_hybris.sh help --- help"
echo
fi

funExecute(){
    starttime=`date +'%Y-%m-%d %H:%M:%S'`
    echo
    echo "Command [$1] start  time:" $starttime
    
    result=$`$1`
    endtime=`date +'%Y-%m-%d %H:%M:%S'`
    
    echo "Command [$1] finish time:" $endtime
    
   

    if [[ $result =~ "$2" ]] || [ -z "$2" ]
    then
        echo "Command [$1] is successful"
        echo
    else 
        echo "$result"
        echo "Command [$1] is failed"
        echo
        exit
    fi

}

funExecuteByArg(){

    selected_arg=$1
    action=$2
    success_flag=$3


    args="$@"
    if [[ ${args: 2} =~ "$selected_arg" ]] 
    then
        funExecute "$action" "$success_flag"
    fi
   
}

funRemove(){

    if [ -L "$1" ]
    then
        echo "Remove link $1"
        rm "$1"
    elif [ -d "$1" ] || [ -f "$1" ]
    then
        echo "Remove $1"
        rm  -rf "$1"
    else
        echo "Don't find $1"
    fi
}

funGenerate(){

    sourcePath=$1
    targetPath=$2
    fileName=$3
   
    if [ ! -z $fileName ]
    then
        if [ ! -d $targetPath ]
        then
            echo "Make directory [$targetPath]"
            result=`mkdir -p "$targetPath"`
        fi
        sourcePath="$1/$3"
        targetPath="$2/$3"
    fi
    
    result=$(funIsExisting -c 4 $@)

    if [ "$result" = "y" ]
    then
        echo "Copy [$sourcePath] to [$targetPath]"
        cp -R $sourcePath $targetPath
    else
        echo "Link [$sourcePath] to [$targetPath]"
        ln -s "$sourcePath" "$targetPath"
    fi
}

funHybrisGenFolder(){
    funGenerate "${hybris_path}/$1" "${dev_project_path}/$1" "" $@
}

funIsExisting(){
    selectedArg=$1
    startIndex=`expr $2 + 2`
    index=0
  
    for arg in $* 
    do
        let index+=1
        if [ $index -ge $startIndex ] && [ "$arg" = "$selectedArg" ]
        then
            echo "y"
            break
        fi

    done
}


funLink(){
    echo
    echo ===================== Link source code start =============================
    funRemove ${dev_project_path}/hybris/config/local.properties
    funRemove ${dev_project_path}/hybris/config/localextensions.xml
    funRemove ${dev_project_path}/hybris/bin/custom/$custom_code_folder_name
    funGenerate "${config_code_path}" "${dev_project_path}/hybris/config" "local.properties" $@
    funGenerate "${config_code_path}" "${dev_project_path}/hybris/config" "localextensions.xml" $@
    funGenerate "${custom_code_path}" "${dev_project_path}/hybris/bin/custom" "" $@
    echo ===================== Link source code finish ============================
    echo
}

funStartServer(){

    if [[ $@ =~ "-d" ]] 
    then
        echo ===================== debug mode =======================================
        ./hybrisserver.sh debug
    elif [[ $@ =~ "-h" ]]
    then
        echo ===================== no console mode ==================================
        ./hybrisserver.sh start
    else
        echo ===================== console mode =====================================
        ./hybrisserver.sh
    fi

}



if [ "$1" = "all" ] || [ "$1" = "create" ]
then
    echo ===================== Create development work space =============
    echo START TIME: $(date +"%Y-%m-%d %T")
  
    echo ===================== Remove existing files =====================
    funRemove ${dev_project_path}/build-tools
    funRemove ${dev_project_path}/c4c-integration
    funRemove ${dev_project_path}/hybris-sbg
    funRemove ${dev_project_path}/installer
    funRemove ${dev_project_path}/licenses

    funRemove ${dev_project_path}/hybris


    echo =============== Create hybris project bin folder ================
    
    if [ ! -d "${dev_project_path}/hybris/bin/custom" ]
    then
        mkdir -p "$dev_project_path/hybris/bin/custom"
        echo Create folder: $dev_project_path/hybris/bin/custom
    fi

    funHybrisGenFolder "hybris/bin/modules" $@
    funHybrisGenFolder "hybris/bin/platform" "create" "-c"

    echo ======= Creat hybris project with Hybris package folder =========

    funHybrisGenFolder "build-tools" $@
    funHybrisGenFolder "c4c-integration" $@
    funHybrisGenFolder "hybris-sbg" $@
    funHybrisGenFolder "installer" $@
    funHybrisGenFolder "licenses" $@

    echo ===================== Initialize to build code ==================
    cd ${dev_project_path}/hybris/bin/platform
    . ./setantenv.sh
    ant all

    if [[ "$@" =~ "-l" ]]
    then
        funLink $@
    fi
    echo END TIME: $(date +"%Y-%m-%d %T")

fi


if [ "$1" = "all" ] || [ "$1" = "link" ]
then

    funLink $@
 fi


if [ -d "${dev_project_path}/hybris/bin/platform" ]
then
    cd ${dev_project_path}/hybris/bin/platform
    funExecute ". ./setantenv.sh"
else
  echo Hybirs project is not created.
  exit
fi

if [ ! -d "${dev_project_path}/hybris/bin/custom/$custom_code_folder_name" ]
then
    echo "############# Source code is not linked by Command ./env_hybris.sh link #############"
fi

if [ "$1" = "open" ]
then
    
    cd ${dev_project_path}
    open .

fi

if [ "$1" = "all" ] || [ "$1" = "clean" ]
then
    echo ===================== clean code =======================================
    funExecute "ant clean" "BUILD SUCCESSFUL"
fi

if [ "$1" = "all" ] || [ "$1" = "build" ]
then
    

    if [ "$2" = "-c" ] && [ "$1" = "build" ]
    then
    echo ===================== clean and build code =============================
        funExecute "ant clean all" "BUILD SUCCESSFUL"
    else
    echo ===================== build code =======================================
        funExecute "ant all" "BUILD SUCCESSFUL"
    fi
    
fi

if [ "$1" = "update" ]
then
   echo ===================== update database ===================================
        funExecute "ant updatesystem" "BUILD SUCCESSFUL"
   
fi

if [ "$1" = "all" ] || [ "$1" = "init" ]
then
   echo ===================== initialize database ===============================
   funExecute "ant initialize" "BUILD SUCCESSFUL"
   
fi


if [ "$1" = "all" ] || [ "$1" = "start" ]
then
    echo ===================== start server ======================================

    funExecuteByArg "-c" "ant clean all" "BUILD SUCCESSFUL" $@
    funExecuteByArg "-b" "ant all" "BUILD SUCCESSFUL" $@
    funExecuteByArg "-i" "ant initialize" "BUILD SUCCESSFUL" $@
    funExecuteByArg "-u" "ant updatesystem" "BUILD SUCCESSFUL" $@
    funStartServer $@

fi


if [ "$1" = "stop" ]
then
    echo ===================== stop server =======================================
    ./hybrisserver.sh stop
    
fi