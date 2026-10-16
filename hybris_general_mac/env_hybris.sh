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
# Date: 2026-10-10 Version: 1.3


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
 init_config_json_file=${init_config_json_file}

# Config file to update
 update_config_json_file=${update_config_json_file}

# Convert relative config paths to absolute (relative to this script's directory)
for cfg_var in init_config_json_file update_config_json_file; do
    eval "cfg_val=\${$cfg_var}"
    case "${cfg_val}" in
        /*) ;;
        *)  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
            eval "$cfg_var=\"${script_dir}/${cfg_val#./}\""
            ;;
    esac
done

# The absolute path of source code for hybris folder bin/custom
custom_code_path=$code_path/$custom_code_folder_name

# The absolute path of config files for hybris folder config
config_code_path=$code_path/$config_file_folder_name

java_home=${java_home}

#------------------------------------------------------------------------------#
#################################################################################
#################  Set environment variables   ##################################
export HYBRIS_HOME_DIR=${dev_project_path}
export ANT_HOME=${HYBRIS_HOME_DIR}/hybris/bin/platform/apache-ant 
# export PATH=${PATH}:${ANT_HOME}/bin
export INITIAL_ADMIN=${pass_word}
export JAVA_HOME=${java_home}


echo export HYBRIS_HOME_DIR=${dev_project_path}
echo export ANT_HOME=${HYBRIS_HOME_DIR}/hybris/bin/platform/apache-ant
echo export INITIAL_ADMIN=${pass_word}
echo export JAVA_HOME=${java_home}

########### DON'T CHANGE FOLLOWING CODE! ###########

if [ "${dev_project_path}" = "." ]
then
     dev_project_path=$(cd `dirname $0`; pwd)
fi

config_json_path=${dev_project_path}/${config_json}

echo
echo "------------------------- Current environment path (Hybris)---------------------------------------------------"
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
echo "      " "./env_hybris.sh upgrade --- Upgrade SAP Commerce package: backup data, replace platform/modules, restore data, ant clean all. -u run ant updatesystem (with config json) after upgrade"
echo "      " "./env_hybris.sh link --- Link(ln) custom folder and config file (local.properties and localextensions.xml), -c means copy command (cp)"
echo "      " "./env_hybris.sh clean --- ant clean"
echo "      " "./env_hybris.sh build --- ant all. -c \"ant clean\" and \"ant all\""
echo "      " "./env_hybris.sh update --- ant updatesystem with config json file (type system + localizations only)"
echo "      " "./env_hybris.sh renewlicense --- Renew expired demo license (delete & recreate temp license, default product CPS_SQL)"
echo "      " "./env_hybris.sh init --- ant initialize, -j run with config json file"
echo "      " "./env_hybris.sh start --- start server. -d \"debug\", -c \"ant clean\", -b \"ant all\", -h without console outprint,"
echo "      " "-i \"ant initialize\", -u \"ant updatesystem\", -j run with config json file"
echo
echo "      " "./env_hybris.sh all --- execute \"create\", \"link\", \"ant clean all\", \"init\", \"start\". -c means copy command (cp), , -j run with config json file"
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

    # Check and release hybris ports before starting
    echo ===================== check port occupancy ============================
    # 8000=JDWP debug, 8983=Solr, 9001=HAC, 9002=Backoffice
    local hybris_ports=("8000" "8983" "9001" "9002")

    # Detect whether any port is occupied
    local port_occupied="no"
    for port in "${hybris_ports[@]}"; do
        if [ -n "$(lsof -ti :${port} 2>/dev/null)" ]; then
            port_occupied="yes"
            echo "Port ${port} is in use."
        fi
    done

    if [ "${port_occupied}" = "yes" ]; then
        # Step 1: try graceful stop first (releases Solr index lock / DB transaction)
        echo "Trying graceful stop..."
        ./hybrisserver.sh stop >/dev/null 2>&1 &
        local stop_pid=$!
        # wait up to 15s for graceful stop to finish
        for i in $(seq 1 15); do
            if ! kill -0 ${stop_pid} 2>/dev/null; then
                break
            fi
            sleep 1
        done
        kill -9 ${stop_pid} 2>/dev/null

        # Step 2: force kill any port still occupied
        for port in "${hybris_ports[@]}"; do
            local pids=$(lsof -ti :${port} 2>/dev/null)
            if [ -n "${pids}" ]; then
                echo "Port ${port} still in use by PID(s): ${pids}, killing..."
                for pid in ${pids}; do
                    kill -9 ${pid} 2>/dev/null
                done
                sleep 2
                echo "Port ${port} released."
            fi
        done
    else
        echo "No hybris port occupied."
    fi

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


if [ "$1" = "upgrade" ]
then
    echo ===================== Upgrade SAP Commerce package =====================
    echo START TIME: $(date +"%Y-%m-%d %T")

    # 1. Backup data directories (hsqldb, media, solr) to a tar archive
    #    tar is much faster than cp -R/rsync for many small files
    #    No compression: binary data (images/DB) won't shrink, compression only adds CPU overhead
    backup_timestamp=$(date +"%Y%m%d_%H%M%S")
    backup_file="${dev_project_path}/../data_backup_${backup_timestamp}.tar"
    echo "Backing up data to ${backup_file}"
    data_dirs_to_backup=""
    for data_dir in hsqldb media solr; do
        if [ -d "${dev_project_path}/hybris/data/${data_dir}" ]; then
            data_dirs_to_backup="${data_dirs_to_backup} ${data_dir}"
        fi
    done
    if [ -n "${data_dirs_to_backup}" ]; then
        tar -cf "${backup_file}" -C "${dev_project_path}/hybris/data" ${data_dirs_to_backup}
        echo "Backup complete: $(du -sh "${backup_file}" | cut -f1)"
    fi

    # 2. Remove old project files (skip c4c-integration, may not exist in new package)
    echo ===================== Remove existing files =====================
    funRemove ${dev_project_path}/build-tools
    funRemove ${dev_project_path}/hybris-sbg
    funRemove ${dev_project_path}/installer
    funRemove ${dev_project_path}/licenses
    funRemove ${dev_project_path}/hybris

    # 3. Create hybris project bin folder
    echo =============== Create hybris project bin folder ================
    if [ ! -d "${dev_project_path}/hybris/bin/custom" ]; then
        mkdir -p "${dev_project_path}/hybris/bin/custom"
        echo "Create folder: ${dev_project_path}/hybris/bin/custom"
    fi

    # 4. Copy modules and platform (always copy, never symlink)
    funHybrisGenFolder "hybris/bin/modules" "upgrade" "-c"
    funHybrisGenFolder "hybris/bin/platform" "upgrade" "-c"

    # 5. Copy/link other folders (skip c4c-integration)
    echo ======= Create hybris project with Hybris package folder =========
    funHybrisGenFolder "build-tools" $@
    funHybrisGenFolder "hybris-sbg" $@
    funHybrisGenFolder "installer" $@
    funHybrisGenFolder "licenses" $@

    # 6. Initial build (creates hybris/data with empty hsqldb/media/solr)
    echo ===================== Initialize to build code ==================
    cd ${dev_project_path}/hybris/bin/platform
    . ./setantenv.sh
    ant all

    # 7. Remove newly created empty data dirs and restore from backup
    echo ===================== Restore data from backup ==================
    for data_dir in hsqldb media solr; do
        funRemove "${dev_project_path}/hybris/data/${data_dir}"
    done
    if [ -f "${backup_file}" ]; then
        tar -xf "${backup_file}" -C "${dev_project_path}/hybris/data"
        echo "Restored data from ${backup_file}"
    fi

    # 8. Link source code
    funLink $@

    # 9. Clean build
    ant clean all

    # 10. Renew demo license (restored DB may have expired license)
    echo ===================== renew license ====================================
    lic_product="CPS_SQL"
    lic_get_output=$(./license.sh -get 2>&1)
    lic_system_id=$(echo "${lic_get_output}" | grep -i "System ID" | sed 's/.*: *//')
    lic_hw_key=$(echo "${lic_get_output}" | grep -i "Hardware Key" | sed 's/.*: *//')
    echo "System ID: ${lic_system_id}, Hardware Key: ${lic_hw_key}, Product: ${lic_product}"
    lic_temp_output=$(./license.sh -temp ${lic_product} 2>&1)
    echo "${lic_temp_output}" | grep -v "deprecated\|Warning\|Deprecated\|---\|Please note\|Loading optional" | grep -v "^$"
    if echo "${lic_temp_output}" | grep -q "already exists"; then
        echo "Deleting existing temporary license..."
        ./license.sh -delete ${lic_system_id} ${lic_hw_key} ${lic_product} 2>&1 | grep -v "deprecated\|Warning\|Deprecated\|---\|Please note\|Loading optional" | grep -v "^$"
        echo "Reinstalling temporary license..."
        ./license.sh -temp ${lic_product} 2>&1 | grep -v "deprecated\|Warning\|Deprecated\|---\|Please note\|Loading optional" | grep -v "^$"
    fi

    # 11. Optional: run ant updatesystem (with -u flag)
    if [[ "$@" =~ "-u" ]]; then
        echo ===================== update database ===================================
        echo "Using config file: ${update_config_json_file}"
        funExecute "ant updatesystem -DconfigFile=${update_config_json_file}" "BUILD SUCCESSFUL"
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
    . ./setantenv.sh
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

if [ "$1" = "ant" ]
then
    $*
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
   echo "Using config file: ${update_config_json_file}"
   funExecute "ant updatesystem -DconfigFile=${update_config_json_file}" "BUILD SUCCESSFUL"
fi

if [ "$1" = "renewlicense" ]
then
    echo ===================== Renew SAP Commerce demo license =====================
    # Default product: CPS_SQL (HSQLDB). Override via 2nd arg, e.g. ./env_hybris.sh renewlicense CPS_MYS
    lic_product="${2:-CPS_SQL}"

    # Step 1: get System ID and Hardware Key
    lic_get_output=$(./license.sh -get 2>&1)
    lic_system_id=$(echo "${lic_get_output}" | grep -i "System ID" | sed 's/.*: *//')
    lic_hw_key=$(echo "${lic_get_output}" | grep -i "Hardware Key" | sed 's/.*: *//')
    echo "System ID: ${lic_system_id}, Hardware Key: ${lic_hw_key}, Product: ${lic_product}"

    # Step 2: try to install temporary license
    lic_temp_output=$(./license.sh -temp ${lic_product} 2>&1)
    echo "${lic_temp_output}" | grep -v "deprecated\|Warning\|Deprecated\|---\|Please note\|Loading optional" | grep -v "^$"

    # Step 3: if already exists, delete old one and retry
    if echo "${lic_temp_output}" | grep -q "already exists"; then
        echo "Deleting existing temporary license..."
        ./license.sh -delete ${lic_system_id} ${lic_hw_key} ${lic_product} 2>&1 | grep -v "deprecated\|Warning\|Deprecated\|---\|Please note\|Loading optional" | grep -v "^$"
        echo "Reinstalling temporary license..."
        ./license.sh -temp ${lic_product} 2>&1 | grep -v "deprecated\|Warning\|Deprecated\|---\|Please note\|Loading optional" | grep -v "^$"
    fi
fi

if [ "$1" = "all" ] || [ "$1" = "init" ]
then
   echo ===================== initialize database ===============================
   if [[ "$@" =~ "-j" ]]
   then
        funExecute "ant initialize -DconfigFile=${init_config_json_file}" "BUILD SUCCESSFUL"
    else
        funExecute "ant initialize" "BUILD SUCCESSFUL"
    fi

fi


if [ "$1" = "all" ] || [ "$1" = "start" ]
then
    echo ===================== start server ======================================

    funExecuteByArg "-c" "ant clean all" "BUILD SUCCESSFUL" $@
    funExecuteByArg "-b" "ant all" "BUILD SUCCESSFUL" $@
    if [[ $@ =~ "-j" ]]
    then
        funExecuteByArg "-i" "ant initialize  -DconfigFile=${init_config_json_file}" "BUILD SUCCESSFUL" $@
        funExecuteByArg "-u" "ant updatesystem  -DconfigFile=${update_config_json_file}" "BUILD SUCCESSFUL" $@
    else
        funExecuteByArg "-i" "ant initialize" "BUILD SUCCESSFUL" $@
        funExecuteByArg "-u" "ant updatesystem" "BUILD SUCCESSFUL" $@
    fi

    funStartServer $@

fi


if [ "$1" = "stop" ]
then
    echo ===================== stop server =======================================
    ./hybrisserver.sh stop
    
fi