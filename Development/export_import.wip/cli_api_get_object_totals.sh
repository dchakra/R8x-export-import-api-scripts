#!/bin/bash
#
# SCRIPT Object count totals
#
ScriptVersion=00.30.00
ScriptDate=2018-09-21

#

export APIScriptVersion=v00x30x00
ScriptName=cli_api_get_object_totals

# =================================================================================================
# =================================================================================================
# START script
# =================================================================================================
# =================================================================================================


# =================================================================================================
# -------------------------------------------------------------------------------------------------
# START Initial Script Setup
# -------------------------------------------------------------------------------------------------

# -------------------------------------------------------------------------------------------------
# =================================================================================================
# START:  Setup Root Parameters
# =================================================================================================

export DATE=`date +%Y-%m-%d-%H%M%Z`
export DATEDTGS=`date +%Y-%m-%d-%H%M%S%Z`

export APICLIlogfilepath=/var/tmp/$ScriptName'_'$APIScriptVersion'_'$DATEDTGS.log

# Configure basic information for formation of file path for command line parameter handler script
#
# cli_api_cmdlineparm_handler_root - root path to command line parameter handler script
# cli_api_cmdlineparm_handler_folder - folder for under root path to command line parameter handler script
# cli_api_cmdlineparm_handler_file - filename, without path, for command line parameter handler script
#
export cli_api_cmdlineparm_handler_root=.
export cli_api_cmdlineparm_handler_folder=common
export cli_api_cmdlineparm_handler_file=cmd_line_parameters_handler.action.common.005.v$ScriptVersion.sh

# ADDED 2018-09-21 -
export gaia_version_handler_root=.
export gaia_version_handler_folder=common
export gaia_version_handler_file=identify_gaia_and_installation.action.common.005.v$ScriptVersion.sh


# -------------------------------------------------------------------------------------------------
# Root script declarations
# -------------------------------------------------------------------------------------------------

# ADDED 2018-05-03 -

# ================================================================================================
# NOTE:  
#   DefaultMgmtAdmin value is used to set the APICLIadmin value in the setup for logon.  This is
#   the default fall back value if the --user parameter is not used to set the actual management 
#   server admininstrator name.  This value should be set to the organizational standard to
#   simplify operation, since it is the default that is used for mgmt_cli login user, where the
#   password must still be entered
# ================================================================================================

#export DefaultMgmtAdmin=admin
export DefaultMgmtAdmin=administrator


# 2018-05-02 - script type - object totals

export script_use_publish="false"

export script_use_export="true"
export script_use_import="false"
export script_use_delete="false"
export script_use_csvfile="false"

export script_dump_json="false"
export script_dump_standard="false"
export script_dump_full="false"
export script_dump_csv="false"

export script_uses_wip="false"
export script_uses_wip_json="false"

# Wait time in seconds
export WAITTIME=15



# -------------------------------------------------------------------------------------------------
# Set parameters for Main operations
# -------------------------------------------------------------------------------------------------

# MODIFIED 2018-05-04 \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
#

export FileExtJSON=json
export FileExtCSV=csv
export FileExtTXT=txt

export APICLIfileexportpre=dump_

export APICLIfileexportext=$FileExtJSON
export APICLIfileexportsuffix=$DATE'.'$APICLIfileexportext

export APICLICSVfileexportext=$FileExtCSV
export APICLICSVfileexportsuffix='.'$APICLICSVfileexportext

export APICLIJSONfileexportext=$FileExtJSON
export APICLIJSONfileexportsuffix='.'$APICLIJSONfileexportext

export APICLIObjectLimit=500

# Configure basic information for formation of file path for action handler scripts
#
# APIScriptActionFileRoot - root path to for action handler scripts
# APIScriptActionFileFolder - folder under root path to for action handler scripts
# APIScriptActionFilePath - path, for action handler scripts
#
export APIScriptActionFileRoot=.
export APIScriptActionFileFolder=

export APIScriptActionFilePrefix=cli_api_export_objects

export APIScriptJSONActionFilename=$APIScriptActionFilePrefix'_actions'.sh
#export APIScriptJSONActionFilename=$APIScriptActionFilePrefix'_actions_'$APIScriptVersion.sh

export APIScriptCSVActionFilename=$APIScriptActionFilePrefix'_actions_to_csv'.sh
#export APIScriptCSVActionFilename=$APIScriptActionFilePrefix'_actions_to_csv_'$APIScriptVersion.sh

#
# /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\ MODIFIED 2018-05-04

# -------------------------------------------------------------------------------------------------


# =================================================================================================
# END:  Setup Root Parameters
# =================================================================================================
# -------------------------------------------------------------------------------------------------

echo | tee -a -i $APICLIlogfilepath
echo 'Script:  '$ScriptName'  Script Version: '$APIScriptVersion | tee -a -i $APICLIlogfilepath

# -------------------------------------------------------------------------------------------------
# Handle important basics
# -------------------------------------------------------------------------------------------------

# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------
# Start of procedures block
# -------------------------------------------------------------------------------------------------

# -------------------------------------------------------------------------------------------------
# ConfigureJQLocation - Configure the value of JQ based on installation
# -------------------------------------------------------------------------------------------------

# MODIFIED 2018-05-02 -\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
#

#
# ConfigureJQLocation - Configure the value of JQ based on installation
#

ConfigureJQLocation () {

    # variable JQ points to where jq is installed
    
    # Apparently MDM, MDS, and Domains don't agree on who sets CPDIR, so better to check!

    #export JQ=${CPDIR}/jq/jq

    if [ -r ${CPDIR}/jq/jq ] ; then
        export JQ=${CPDIR}/jq/jq
    elif [ -r /opt/CPshrd-R80/jq/jq ] ; then
        export JQ=/opt/CPshrd-R80/jq/jq
    else
        echo "Missing jq, not found in ${CPDIR}/jq/jq or /opt/CPshrd-R80/jq/jq" | tee -a -i $APICLIlogfilepath
        echo 'Critical Error - Exiting Script !!!!' | tee -a -i $APICLIlogfilepath
        echo | tee -a -i $APICLIlogfilepath
        echo "Log output in file $APICLIlogfilepath" | tee -a -i $APICLIlogfilepath
        echo | tee -a -i $APICLIlogfilepath
        exit 1
    fi
    
    return 0
}

#
# \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/-  MODIFIED 2018-05-02

# -------------------------------------------------------------------------------------------------
# ScriptAPIVersionCheck - Check version of the script to ensure it is able to operate at minimum expected
# -------------------------------------------------------------------------------------------------

# MODIFIED 2018-05-02 -\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
#

#
# ScriptAPIVersionCheck - Check version of the script to ensure it is able to operate at minimum 
# expected to correctly execute.
#

ScriptAPIVersionCheck () {

    getapiversion=$(mgmt_cli show api-versions -r true -f json --port $currentapisslport | $JQ '.["current-version"]' -r)
    export checkapiversion=$getapiversion
    if [ $checkapiversion = null ] ; then
        # show api-versions does not exist in version 1.0, so it fails and returns null
        currentapiversion=1.0
    else
        currentapiversion=$checkapiversion
    fi
    
    echo 'API version = '$currentapiversion | tee -a -i $APICLIlogfilepath
    
    if [ $(expr $minapiversionrequired '<=' $currentapiversion) ] ; then
        # API is sufficient version
        echo | tee -a -i $APICLIlogfilepath
    else
        # API is not of a sufficient version to operate
        echo | tee -a -i $APICLIlogfilepath
        echo 'Current API Version ('$currentapiversion') does not meet minimum API version requirement ('$minapiversionrequired')' | tee -a -i $APICLIlogfilepath
        echo | tee -a -i $APICLIlogfilepath
        echo '! termination execution !' | tee -a -i $APICLIlogfilepath
        echo | tee -a -i $APICLIlogfilepath
        exit 250
    fi
    
    echo | tee -a -i $APICLIlogfilepath
    return 0
}

#
# \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/-  MODIFIED 2018-05-02

# -------------------------------------------------------------------------------------------------
# CheckAPIScriptVerboseOutput - Check if verbose output is configured externally
# -------------------------------------------------------------------------------------------------

# MODIFIED 2018-05-02 -\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
#

#
# CheckAPIScriptVerboseOutput - Check if verbose output is configured externally via shell level 
# parameter setting, if it is, the check it for correct and valid values; otherwise, if set, then
# reset to false because wrong.
#

CheckAPIScriptVerboseOutput () {

    if [ -z $APISCRIPTVERBOSE ] ; then
        # Verbose mode not set from shell level
        echo "!! Verbose mode not set from shell level" | tee -a -i $APICLIlogfilepath
        export APISCRIPTVERBOSE=false
        echo | tee -a -i $APICLIlogfilepath
    elif [ x"`echo "$APISCRIPTVERBOSE" | tr '[:upper:]' '[:lower:]'`" = x"false" ] ; then
        # Verbose mode set OFF from shell level
        echo "!! Verbose mode set OFF from shell level" | tee -a -i $APICLIlogfilepath
        export APISCRIPTVERBOSE=false
        echo | tee -a -i $APICLIlogfilepath
    elif [ x"`echo "$APISCRIPTVERBOSE" | tr '[:upper:]' '[:lower:]'`" = x"true" ] ; then
        # Verbose mode set ON from shell level
        echo "!! Verbose mode set ON from shell level" | tee -a -i $APICLIlogfilepath
        export APISCRIPTVERBOSE=true
        echo | tee -a -i $APICLIlogfilepath
        echo 'Script :  '$0 | tee -a -i $APICLIlogfilepath
        echo 'Verbose mode enabled' | tee -a -i $APICLIlogfilepath
        echo | tee -a -i $APICLIlogfilepath
    else
        # Verbose mode set to wrong value from shell level
        echo "!! Verbose mode set to wrong value from shell level >"$APISCRIPTVERBOSE"<" | tee -a -i $APICLIlogfilepath
        echo "!! Settting Verbose mode OFF, pending command line parameter checking!" | tee -a -i $APICLIlogfilepath
        export APISCRIPTVERBOSE=false
        echo | tee -a -i $APICLIlogfilepath
    fi
    
    export APISCRIPTVERBOSECHECK=true

    echo | tee -a -i $APICLIlogfilepath
    return 0
}

#
# \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/-  MODIFIED 2018-05-02

# -------------------------------------------------------------------------------------------------
# End of procedures block
# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------

# variable JQ points to where jq is installed
export JQ=${CPDIR}/jq/jq

ConfigureJQLocation

export currentapisslport=$(clish -c "show web ssl-port" | cut -d " " -f 2)
echo 'Current Gaia web ssl-port : '$currentapisslport >> $APICLIlogfilepath

export minapiversionrequired=1.0
export checkapiversion=

ScriptAPIVersionCheck

# We want to leave som externally set variables as they were
#
#export APISCRIPTVERBOSE=false

export APISCRIPTVERBOSECHECK=false

CheckAPIScriptVerboseOutput


# -------------------------------------------------------------------------------------------------
# END Initial Script Setup
# -------------------------------------------------------------------------------------------------
# =================================================================================================


# =================================================================================================
# =================================================================================================
# START:  Command Line Parameter Handling and Help
# =================================================================================================

# MODIFIED 2018-09-21 \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
#


#
# Standard R8X API Scripts Command Line Parameters
#
# -? | --help
# -v | --verbose
# -P <web-ssl-port> | --port <web-ssl-port> | -P=<web-ssl-port> | --port=<web-ssl-port>
# -r | --root
# -u <admin_name> | --user <admin_name> | -u=<admin_name> | --user=<admin_name>
# -p <password> | --password <password> | -p=<password> | --password=<password>
# -m <server_IP> | --management <server_IP> | -m=<server_IP> | --management=<server_IP>
# -d <domain> | --domain <domain> | -d=<domain> | --domain=<domain>
# -s <session_file_filepath> | --session-file <session_file_filepath> | -s=<session_file_filepath> | --session-file=<session_file_filepath>
# -l <log_path> | --log-path <log_path> | -l=<log_path> | --log-path=<log_path>'
#
# -o <output_path> | --output <output_path> | -o=<output_path> | --output=<output_path> 
#
# -x <export_path> | --export <export_path> | -x=<export_path> | --export=<export_path> 
# -i <import_path> | --import-path <import_path> | -i=<import_path> | --import-path=<import_path>'
# -k <delete_path> | --delete-path <delete_path> | -k=<delete_path> | --delete-path=<delete_path>'
#
# -c <csv_path> | --csv <csv_path> | -c=<csv_path> | --csv=<csv_path>'
#
# --NSO | --no-system-objects
# --SO | --system-objects
#
# --NOWAIT
#
# --CLEANUPWIP
# --NODOMAINFOLDERS
# --CSVEXPORTADDIGNOREERR
#

export SHOWHELP=false
# MODIFIED 2018-09-21 -
#export CLIparm_websslport=443
export CLIparm_websslport=
export CLIparm_rootuser=false
export CLIparm_user=
export CLIparm_password=
export CLIparm_mgmt=
export CLIparm_domain=
export CLIparm_sessionidfile=
export CLIparm_logpath=

export CLIparm_outputpath=
export CLIparm_exportpath=
export CLIparm_importpath=
export CLIparm_deletepath=

export CLIparm_csvpath=

# MODIFIED 2018-06-24 -
#export CLIparm_NoSystemObjects=true
export CLIparm_NoSystemObjects=false

export CLIparm_NOWAIT=
export CLIparm_CLEANUPWIP=
export CLIparm_NODOMAINFOLDERS=
export CLIparm_CSVEXPORTADDIGNOREERR=

# --NOWAIT
#
if [ -z "$NOWAIT" ]; then
    # NOWAIT mode not set from shell level
    export CLIparm_NOWAIT=false
elif [ x"`echo "$NOWAIT" | tr '[:upper:]' '[:lower:]'`" = x"false" ] ; then
    # NOWAIT mode set OFF from shell level
    export CLIparm_NOWAIT=false
elif [ x"`echo "$NOWAIT" | tr '[:upper:]' '[:lower:]'`" = x"true" ] ; then
    # NOWAIT mode set ON from shell level
    export CLIparm_NOWAIT=true
else
    # NOWAIT mode set to wrong value from shell level
    export CLIparm_NOWAIT=false
fi

# --CLEANUPWIP
#
if [ -z "$CLEANUPWIP" ]; then
    # CLEANUPWIP mode not set from shell level
    export CLIparm_CLEANUPWIP=false
elif [ x"`echo "$CLEANUPWIP" | tr '[:upper:]' '[:lower:]'`" = x"false" ] ; then
    # CLEANUPWIP mode set OFF from shell level
    export CLIparm_CLEANUPWIP=false
elif [ x"`echo "$CLEANUPWIP" | tr '[:upper:]' '[:lower:]'`" = x"true" ] ; then
    # CLEANUPWIP mode set ON from shell level
    export CLIparm_CLEANUPWIP=true
else
    # CLEANUPWIP mode set to wrong value from shell level
    export CLIparm_CLEANUPWIP=false
fi

# --NODOMAINFOLDERS
#
if [ -z "$NODOMAINFOLDERS" ]; then
    # NODOMAINFOLDERS mode not set from shell level
    export CLIparm_NODOMAINFOLDERS=false
elif [ x"`echo "$NODOMAINFOLDERS" | tr '[:upper:]' '[:lower:]'`" = x"false" ] ; then
    # NODOMAINFOLDERS mode set OFF from shell level
    export CLIparm_NODOMAINFOLDERS=false
elif [ x"`echo "$NODOMAINFOLDERS" | tr '[:upper:]' '[:lower:]'`" = x"true" ] ; then
    # NODOMAINFOLDERS mode set ON from shell level
    export CLIparm_NODOMAINFOLDERS=true
else
    # NODOMAINFOLDERS mode set to wrong value from shell level
    export CLIparm_NODOMAINFOLDERS=false
fi

# --CSVEXPORTADDIGNOREERR
#
if [ -z "$CSVEXPORTADDIGNOREERR" ]; then
    # CSVEXPORTADDIGNOREERR mode not set from shell level
    export CLIparm_CSVEXPORTADDIGNOREERR=false
elif [ x"`echo "$CSVEXPORTADDIGNOREERR" | tr '[:upper:]' '[:lower:]'`" = x"false" ] ; then
    # CSVEXPORTADDIGNOREERR mode set OFF from shell level
    export CLIparm_CSVEXPORTADDIGNOREERR=false
elif [ x"`echo "$CSVEXPORTADDIGNOREERR" | tr '[:upper:]' '[:lower:]'`" = x"true" ] ; then
    # CSVEXPORTADDIGNOREERR mode set ON from shell level
    export CLIparm_CSVEXPORTADDIGNOREERR=true
else
    # CLEANUPWIP mode set to wrong value from shell level
    export CLIparm_CSVEXPORTADDIGNOREERR=false
fi

export REMAINS=

#
# /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\ MODIFIED 2018-09-21

# =================================================================================================
# -------------------------------------------------------------------------------------------------
# START:  Local Help display proceedure
# -------------------------------------------------------------------------------------------------

# MODIFIED 2018-09-21 \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
#

# Show local help information.  Add script specific information here to show when help requested

doshowlocalhelp () {
    #
    # Screen width template for sizing, default width of 80 characters assumed
    #
    #              1111111111222222222233333333334444444444555555555566666666667777777777888888888899999999990
    #    01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
    echo
    echo 'Local Help Information : '

    #              1111111111222222222233333333334444444444555555555566666666667777777777888888888899999999990
    #    01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
    echo
    
    #              1111111111222222222233333333334444444444555555555566666666667777777777888888888899999999990
    #    01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890

    echo
    return 1
}

#
# /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\ MODIFIED 2018-09-21

# -------------------------------------------------------------------------------------------------
# END:  Local Help display proceedure
# -------------------------------------------------------------------------------------------------
# =================================================================================================

# -------------------------------------------------------------------------------------------------
# CommandLineParameterHandler - Command Line Parameter Handler calling routine
# -------------------------------------------------------------------------------------------------

# MODIFIED 2018-05-03 -\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
#

CommandLineParameterHandler () {
    #
    # CommandLineParameterHandler - Command Line Parameter Handler calling routine
    #
    
    echo | tee -a -i $APICLIlogfilepath
    echo '--------------------------------------------------------------------------' | tee -a -i $APICLIlogfilepath
    echo | tee -a -i $APICLIlogfilepath
    echo "Calling external Command Line Paramenter Handling Script" | tee -a -i $APICLIlogfilepath
    echo " - External Script : "$cli_api_cmdlineparm_handler | tee -a -i $APICLIlogfilepath
    echo | tee -a -i $APICLIlogfilepath
    
    . $cli_api_cmdlineparm_handler "$@"
    
    echo | tee -a -i $APICLIlogfilepath
    echo "Returned from external Command Line Paramenter Handling Script" | tee -a -i $APICLIlogfilepath
    echo | tee -a -i $APICLIlogfilepath
    
    if [ "$APISCRIPTVERBOSE" = "true" ] && [ "$NOWAIT" != "true" ] ; then
        echo
        read -t $WAITTIME -n 1 -p "Any key to continue.  Automatic continue after $WAITTIME seconds : " anykey
    fi
    
    echo | tee -a -i $APICLIlogfilepath
    echo "Starting local execution" | tee -a -i $APICLIlogfilepath
    echo | tee -a -i $APICLIlogfilepath
    echo '--------------------------------------------------------------------------' | tee -a -i $APICLIlogfilepath
    echo | tee -a -i $APICLIlogfilepath
    
}

#
# \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/-  MODIFIED 2018-05-03

# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------

# -------------------------------------------------------------------------------------------------
# Call command line parameter handler action script
# -------------------------------------------------------------------------------------------------

# MODIFIED 2018-05-03-3 -

export cli_api_cmdlineparm_handler_path=$cli_api_cmdlineparm_handler_root/$cli_api_cmdlineparm_handler_folder

export cli_api_cmdlineparm_handler=$cli_api_cmdlineparm_handler_path/$cli_api_cmdlineparm_handler_file

# Check that we can finde the command line parameter handler file
#
if [ ! -r $cli_api_cmdlineparm_handler ] ; then
    # no file found, that is a problem
    echo | tee -a -i $APICLIlogfilepath
    echo 'Command Line Parameter handler script file missing' | tee -a -i $APICLIlogfilepath
    echo '  File not found : '$cli_api_cmdlineparm_handler | tee -a -i $APICLIlogfilepath
    echo | tee -a -i $APICLIlogfilepath
    echo 'Other parameter elements : ' | tee -a -i $APICLIlogfilepath
    echo '  Root of folder path : '$cli_api_cmdlineparm_handler_root | tee -a -i $APICLIlogfilepath
    echo '  Folder in Root path : '$cli_api_cmdlineparm_handler_folder | tee -a -i $APICLIlogfilepath
    echo '  Folder Root path    : '$cli_api_cmdlineparm_handler_path | tee -a -i $APICLIlogfilepath
    echo '  Script Filename     : '$cli_api_cmdlineparm_handler_file | tee -a -i $APICLIlogfilepath
    echo | tee -a -i $APICLIlogfilepath
    echo 'Critical Error - Exiting Script !!!!' | tee -a -i $APICLIlogfilepath
    echo | tee -a -i $APICLIlogfilepath
    echo "Log output in file $APICLIlogfilepath" | tee -a -i $APICLIlogfilepath
    echo | tee -a -i $APICLIlogfilepath

    exit 251
fi

# MODIFIED 2018-05-03-3 -

CommandLineParameterHandler "$@"


# -------------------------------------------------------------------------------------------------
# Local Handle request for help and return
# -------------------------------------------------------------------------------------------------

# MODIFIED 2018-09-21 \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
#

#
# Was help requested, if so show local content and return
#
if [ x"$SHOWHELP" = x"true" ] ; then
    # Show Local Help
    doshowlocalhelp
    exit 255 
fi

#
# /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\ MODIFIED 2018-09-21

# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------


# =================================================================================================
# END:  Command Line Parameter Handling and Help
# =================================================================================================
# =================================================================================================


# =================================================================================================
# =================================================================================================
# START:  Setup Standard Parameters
# =================================================================================================

if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
    echo 'Date Time Group   :  '$DATE | tee -a -i $APICLIlogfilepath
    echo 'Date Time Group S :  '$DATEDTGS | tee -a -i $APICLIlogfilepath
    echo | tee -a -i $APICLIlogfilepath
fi

# -------------------------------------------------------------------------------------------------
# GetGaiaVersionAndInstallationType - Gaia version and installation type Handler calling routine
# -------------------------------------------------------------------------------------------------

# MODIFIED 2018-09-21 -\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
#

GetGaiaVersionAndInstallationType () {
    #
    # GetGaiaVersionAndInstallationType - Gaia version and installation type Handler calling routine
    #
    
    echo | tee -a -i $APICLIlogfilepath
    echo '--------------------------------------------------------------------------' | tee -a -i $APICLIlogfilepath
    echo | tee -a -i $APICLIlogfilepath
    echo "Calling external Gaia version and installation type Handling Script" | tee -a -i $APICLIlogfilepath
    echo " - External Script : "$gaia_version_handler | tee -a -i $APICLIlogfilepath
    echo | tee -a -i $APICLIlogfilepath
    
    . $gaia_version_handler "$@"
    
    echo | tee -a -i $APICLIlogfilepath
    echo "Returned from external Gaia version and installation type Handling Script" | tee -a -i $APICLIlogfilepath
    echo | tee -a -i $APICLIlogfilepath
    
    if [ "$APISCRIPTVERBOSE" = "true" ] && [ "$NOWAIT" != "true" ] ; then
        echo
        read -t $WAITTIME -n 1 -p "Any key to continue.  Automatic continue after $WAITTIME seconds : " anykey
    fi
    
    echo | tee -a -i $APICLIlogfilepath
    echo "Continueing local execution" | tee -a -i $APICLIlogfilepath
    echo | tee -a -i $APICLIlogfilepath
    echo '--------------------------------------------------------------------------' | tee -a -i $APICLIlogfilepath
    echo | tee -a -i $APICLIlogfilepath
    
}

#
# \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/-  MODIFIED 2018-09-21

# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------

# -------------------------------------------------------------------------------------------------
# Call Gaia version and installation type Handler action script
# -------------------------------------------------------------------------------------------------

# MODIFIED 2018-09-21 -\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
#

export gaia_version_handler_path=$gaia_version_handler_root/$gaia_version_handler_folder

export gaia_version_handler=$gaia_version_handler_path/$gaia_version_handler_file

# Check that we can finde the command line parameter handler file
#
if [ ! -r $gaia_version_handler ] ; then
    # no file found, that is a problem
    echo | tee -a -i $APICLIlogfilepath
    echo ' Gaia version and installation type handler script file missing' | tee -a -i $APICLIlogfilepath
    echo '  File not found : '$gaia_version_handler | tee -a -i $APICLIlogfilepath
    echo | tee -a -i $APICLIlogfilepath
    echo 'Other parameter elements : ' | tee -a -i $APICLIlogfilepath
    echo '  Root of folder path : '$gaia_version_handler_root | tee -a -i $APICLIlogfilepath
    echo '  Folder in Root path : '$gaia_version_handler_folder | tee -a -i $APICLIlogfilepath
    echo '  Folder Root path    : '$gaia_version_handler_path | tee -a -i $APICLIlogfilepath
    echo '  Script Filename     : '$gaia_version_handler_file | tee -a -i $APICLIlogfilepath
    echo | tee -a -i $APICLIlogfilepath
    echo 'Critical Error - Exiting Script !!!!' | tee -a -i $APICLIlogfilepath
    echo | tee -a -i $APICLIlogfilepath
    echo "Log output in file $APICLIlogfilepath" | tee -a -i $APICLIlogfilepath
    echo | tee -a -i $APICLIlogfilepath

    exit 251
fi

#
# \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/-  MODIFIED 2018-09-21

GetGaiaVersionAndInstallationType "$@"


# =================================================================================================
# END:  Setup Standard Parameters
# =================================================================================================
# =================================================================================================


# =================================================================================================
# =================================================================================================
# START:  Setup Login Parameters and Mgmt_CLI handler procedures
# =================================================================================================


# -------------------------------------------------------------------------------------------------
# HandleMgmtCLIPublish - publish changes if needed
# -------------------------------------------------------------------------------------------------

# MODIFIED 2018-05-02-2 -\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
#

#
# HandleMgmtCLIPublish - publish changes if needed
#

HandleMgmtCLIPublish () {
    #
    # HandleMgmtCLIPublish - publish changes if needed
    #
    
    if [ x"$script_use_publish" = x"true" ] ; then
        echo | tee -a -i $APICLIlogfilepath
        echo 'Publish changes!' | tee -a -i $APICLIlogfilepath
        echo | tee -a -i $APICLIlogfilepath
        mgmt_cli publish -s $APICLIsessionfile | tee -a -i $APICLIlogfilepath
        echo | tee -a -i $APICLIlogfilepath
    else
        echo | tee -a -i $APICLIlogfilepath
        echo 'Nothing to Publish!' | tee -a -i $APICLIlogfilepath
        echo | tee -a -i $APICLIlogfilepath
    fi
    
    return 0
}

#
# \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/-  MODIFIED 2018-05-02-2

# -------------------------------------------------------------------------------------------------
# HandleMgmtCLILogout - Logout from mgmt_cli, also cleanup session file
# -------------------------------------------------------------------------------------------------

# MODIFIED 2018-05-02-2 -\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
#

#
# Logout from mgmt_cli, also cleanup session file
#

HandleMgmtCLILogout () {
    #
    # HandleMgmtCLILogout - Logout from mgmt_cli, also cleanup session file
    #

    echo | tee -a -i $APICLIlogfilepath
    echo 'Logout of mgmt_cli!  Then remove session file : '$APICLIsessionfile | tee -a -i $APICLIlogfilepath
    echo | tee -a -i $APICLIlogfilepath
    mgmt_cli logout -s $APICLIsessionfile | tee -a -i $APICLIlogfilepath
    
    rm $APICLIsessionfile | tee -a -i $APICLIlogfilepath
    rm $APICLIsessionerrorfile | tee -a -i $APICLIlogfilepath
    
    return 0
}

#
# \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/-  MODIFIED 2018-05-02-2

# -------------------------------------------------------------------------------------------------
# HandleMgmtCLILogin - Login to the API via mgmt_cli login
# -------------------------------------------------------------------------------------------------

# MODIFIED 2018-05-04-3 -\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
#

#
# Login to the API via mgmt_cli login
#

HandleMgmtCLILogin () {
    #
    # Login to the API via mgmt_cli login
    #

    export loginstring=
    export loginparmstring=
    
# MODIFIED 2018-05-04 -
    export APICLIsessionerrorfile=id.`date +%Y%m%d-%H%M%S%Z`.err

# MODIFIED 2018-05-03 -
    if [ ! -z "$CLIparm_sessionidfile" ] ; then
        # CLIparm_sessionidfile value is set so use it
        export APICLIsessionfile=$CLIparm_sessionidfile
    else
        # Updated to make session id file unique in case of multiple admins running script from same folder
        export APICLIsessionfile=id.`date +%Y%m%d-%H%M%S%Z`.txt
    fi

# MODIFIED 2018-05-03 -
    export domainnamenospace=
    if [ ! -z "$domaintarget" ] ; then
        # Handle domain name that might include space if the value is set
        #export domainnamenospace="$(echo -e "${domaintarget}" | tr -d '[:space:]')"
        #export domainnamenospace=$(echo -e ${domaintarget} | tr -d '[:space:]')
        export domainnamenospace=$(echo -e ${domaintarget} | tr ' ' '_')
    else
        export domainnamenospace=
    fi
    
    if [ ! -z "$domainnamenospace" ] ; then
        # Handle domain name that might include space
        if [ ! -z "$CLIparm_sessionidfile" ] ; then
            # adjust if CLIparm_sessionidfile was set, since that might be a complete path, append the path to it 
            export APICLIsessionfile=$APICLIsessionfile.$domainnamenospace
        else
            # assume the session file is set to a local file and prefix the domain to it
            export APICLIsessionfile=$domainnamenospace.$APICLIsessionfile
        fi
    fi
    
    echo | tee -a -i $APICLIlogfilepath
    echo 'APICLIwebsslport  :  '$APICLIwebsslport | tee -a -i $APICLIlogfilepath
    echo 'Domain Target     :  '$domaintarget | tee -a -i $APICLIlogfilepath
    echo 'Domain no space   :  '$domainnamenospace | tee -a -i $APICLIlogfilepath
    echo 'APICLIsessionfile :  '$APICLIsessionfile | tee -a -i $APICLIlogfilepath
    
    echo | tee -a -i $APICLIlogfilepath
    echo 'mgmt_cli Login!' | tee -a -i $APICLIlogfilepath
    echo | tee -a -i $APICLIlogfilepath

    if [ x"$CLIparm_rootuser" = x"true" ] ; then
        # Handle if ROOT User -r true parameter
        
        echo 'Login to mgmt_cli as root user -r true and save to session file :  '$APICLIsessionfile | tee -a -i $APICLIlogfilepath
        echo | tee -a -i $APICLIlogfilepath
        
        # Handle management server parameter error if combined with ROOT User
        if [ x"$CLIparm_mgmt" != x"" ] ; then
            echo | tee -a -i $APICLIlogfilepath
            echo 'mgmt_cli parameter error!!!!' | tee -a -i $APICLIlogfilepath
            echo 'ROOT User (-r true) parameter can not be combined with -m <Management_Server>!!!' | tee -a -i $APICLIlogfilepath
            echo | tee -a -i $APICLIlogfilepath
            return 254
        fi
    
    	export loginparmstring=' -r true'
    
        if [ x"$domaintarget" != x"" ] ; then
            # Handle domain parameter for login string
            export loginparmstring=$loginparmstring" domain \"$domaintarget\""
    
            #
            # Testing - Dump login string built from parameters
            #
            if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
                echo 'Execute login with loginparmstring '\"$loginparmstring\"' As Root with Domain' | tee -a -i $APICLIlogfilepath
                echo | tee -a -i $APICLIlogfilepath
            fi
            
            mgmt_cli login -r true domain "$domaintarget" --port $APICLIwebsslport > $APICLIsessionfile 2>> $APICLIsessionerrorfile
            EXITCODE=$?
            cat $APICLIsessionerrorfile | tee -a -i $APICLIlogfilepath
        else
            #
            # Testing - Dump login string built from parameters
            #
            if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
                echo 'Execute login with loginparmstring '\"$loginparmstring\"' As Root'
                echo
            fi
            
            mgmt_cli login -r true --port $APICLIwebsslport > $APICLIsessionfile 2>> $APICLIsessionerrorfile
            EXITCODE=$?
            cat $APICLIsessionerrorfile | tee -a -i $APICLIlogfilepath
        fi
    else
        # Handle User
    
        echo 'Login to mgmt_cli as '$APICLIadmin' and save to session file :  '$APICLIsessionfile | tee -a -i $APICLIlogfilepath
        echo | tee -a -i $APICLIlogfilepath
        
        if [ x"$APICLIadmin" != x"" ] ; then
            export loginparmstring=$loginparmstring" user $APICLIadmin"
        else
            echo | tee -a -i $APICLIlogfilepath
            echo 'mgmt_cli parameter error!!!!' | tee -a -i $APICLIlogfilepath
            echo 'Admin User variable not set!!!' | tee -a -i $APICLIlogfilepath
            echo | tee -a -i $APICLIlogfilepath
            return 254
        fi
    
        if [ x"$CLIparm_password" != x"" ] ; then
            # Handle password parameter
            export loginparmstring=$loginparmstring" password \"$CLIparm_password\""
    
            if [ x"$domaintarget" != x"" ] ; then
                # Handle domain parameter for login string
                export loginparmstring=$loginparmstring" domain \"$domaintarget\""
          
                # Handle management server parameter for mgmt_cli parms
                if [ x"$CLIparm_mgmt" != x"" ] ; then
                    export mgmttarget="-m \"$CLIparm_mgmt\""
      
                    #
                    # Testing - Dump login string built from parameters
                    #
                    if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
                        echo 'Execute login with loginparmstring '\"$loginparmstring\"' As User with Password and Domain and Management' | tee -a -i $APICLIlogfilepath
                        echo 'Execute operations with mgmttarget '\"$mgmttarget\" | tee -a -i $APICLIlogfilepath
                        echo | tee -a -i $APICLIlogfilepath
                    fi
                    
                    mgmt_cli login user $APICLIadmin password "$CLIparm_password" domain "$domaintarget" -m "$CLIparm_mgmt" --port $APICLIwebsslport > $APICLIsessionfile 2>> $APICLIsessionerrorfile
                    EXITCODE=$?
                    cat $APICLIsessionerrorfile | tee -a -i $APICLIlogfilepath
                else
                    #
                    # Testing - Dump login string built from parameters
                    #
                    if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
                        echo 'Execute login with loginparmstring '\"$loginparmstring\"' As User with Password and Domain' | tee -a -i $APICLIlogfilepath
                        echo | tee -a -i $APICLIlogfilepath
                    fi
                    
                    mgmt_cli login user $APICLIadmin password "$CLIparm_password" domain "$domaintarget" --port $APICLIwebsslport > $APICLIsessionfile 2>> $APICLIsessionerrorfile
                    EXITCODE=$?
                    cat $APICLIsessionerrorfile | tee -a -i $APICLIlogfilepath
                fi
            else
                # Handle management server parameter for mgmt_cli parms
                if [ x"$CLIparm_mgmt" != x"" ] ; then
                    export mgmttarget='-m \"$CLIparm_mgmt\"'
      
                    #
                    # Testing - Dump login string built from parameters
                    #
                    if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
                        echo 'Execute login with loginparmstring '\"$loginparmstring\"' As User with Password and Management' | tee -a -i $APICLIlogfilepath
                        echo 'Execute operations with mgmttarget '\"$mgmttarget\" | tee -a -i $APICLIlogfilepath
                        echo | tee -a -i $APICLIlogfilepath
                    fi
                    
                    mgmt_cli login user $APICLIadmin password "$CLIparm_password" -m "$CLIparm_mgmt" --port $APICLIwebsslport > $APICLIsessionfile 2>> $APICLIsessionerrorfile
                    EXITCODE=$?
                    cat $APICLIsessionerrorfile | tee -a -i $APICLIlogfilepath
                else
                    #
                    # Testing - Dump login string built from parameters
                    #
                    if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
                        echo 'Execute login with loginparmstring '\"$loginparmstring\"' As User with Password' | tee -a -i $APICLIlogfilepath
                        echo | tee -a -i $APICLIlogfilepath
                    fi
                    
                    mgmt_cli login user $APICLIadmin password "$CLIparm_password" --port $APICLIwebsslport > $APICLIsessionfile 2>> $APICLIsessionerrorfile
                    EXITCODE=$?
                    cat $APICLIsessionerrorfile | tee -a -i $APICLIlogfilepath
                fi
            fi
        else
            # Handle NO password parameter
    
            if [ x"$domaintarget" != x"" ] ; then
                # Handle domain parameter for login string
                export loginparmstring=$loginparmstring" domain \"$domaintarget\""
          
                # Handle management server parameter for mgmt_cli parms
                if [ x"$CLIparm_mgmt" != x"" ] ; then
                    export mgmttarget="-m \"$CLIparm_mgmt\""
      
                    #
                    # Testing - Dump login string built from parameters
                    #
                    if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
                        echo 'Execute login with loginparmstring '\"$loginparmstring\"' As User with Domain and Management' | tee -a -i $APICLIlogfilepath
                        echo 'Execute operations with mgmttarget '\"$mgmttarget\" | tee -a -i $APICLIlogfilepath
                        echo | tee -a -i $APICLIlogfilepath
                    fi
                    
                    mgmt_cli login user $APICLIadmin domain "$domaintarget" -m "$CLIparm_mgmt" --port $APICLIwebsslport > $APICLIsessionfile 2>> $APICLIsessionerrorfile
                    EXITCODE=$?
                    cat $APICLIsessionerrorfile | tee -a -i $APICLIlogfilepath
                else
                    #
                    # Testing - Dump login string built from parameters
                    #
                    if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
                        echo 'Execute login with loginparmstring '\"$loginparmstring\"' As User with Domain | tee -a -i $APICLIlogfilepath'
                        echo | tee -a -i $APICLIlogfilepath
                    fi
                    
                    mgmt_cli login user $APICLIadmin domain "$domaintarget" --port $APICLIwebsslport > $APICLIsessionfile 2>> $APICLIsessionerrorfile
                    EXITCODE=$?
                    cat $APICLIsessionerrorfile | tee -a -i $APICLIlogfilepath
                fi
            else
                # Handle management server parameter for mgmt_cli parms
                if [ x"$CLIparm_mgmt" != x"" ] ; then
                    export mgmttarget='-m \"$CLIparm_mgmt\"'
      
                    #
                    # Testing - Dump login string built from parameters
                    #
                    if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
                        echo 'Execute login with loginparmstring '\"$loginparmstring\"' As User with Management' | tee -a -i $APICLIlogfilepath
                        echo 'Execute operations with mgmttarget '\"$mgmttarget\" | tee -a -i $APICLIlogfilepath
                        echo | tee -a -i $APICLIlogfilepath
                    fi
                    
                    mgmt_cli login user $APICLIadmin -m "$CLIparm_mgmt" --port $APICLIwebsslport > $APICLIsessionfile 2>> $APICLIsessionerrorfile
                    EXITCODE=$?
                    cat $APICLIsessionerrorfile | tee -a -i $APICLIlogfilepath
                else
                    #
                    # Testing - Dump login string built from parameters
                    #
                    if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
                        echo 'Execute login with loginparmstring '\"$loginparmstring\"' As User' | tee -a -i $APICLIlogfilepath
                        echo | tee -a -i $APICLIlogfilepath
                    fi
                    
                    mgmt_cli login user $APICLIadmin --port $APICLIwebsslport > $APICLIsessionfile 2>> $APICLIsessionerrorfile
                    EXITCODE=$?
                    cat $APICLIsessionerrorfile | tee -a -i $APICLIlogfilepath
                fi
            fi
        fi
    fi
    
    if [ "$EXITCODE" != "0" ] ; then
        
        echo | tee -a -i $APICLIlogfilepath
        echo "mgmt_cli login error!" | tee -a -i $APICLIlogfilepath
        echo | tee -a -i $APICLIlogfilepath
        cat $APICLIsessionfile | tee -a -i $APICLIlogfilepath
        echo | tee -a -i $APICLIlogfilepath
        return 255
    
    else
        
        echo "mgmt_cli login success!" | tee -a -i $APICLIlogfilepath
        echo | tee -a -i $APICLIlogfilepath
        cat $APICLIsessionfile | tee -a -i $APICLIlogfilepath
        echo | tee -a -i $APICLIlogfilepath
        
    fi

    return 0
}

#
# \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/-  MODIFIED 2018-05-04-3

# -------------------------------------------------------------------------------------------------
# SetupLogin2MgmtCLI - Setup Login to Management CLI
# -------------------------------------------------------------------------------------------------

# MODIFIED 2018-09-21 -\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
#

SetupLogin2MgmtCLI () {
    #
    # setup the mgmt_cli login fundamentals
    #
    
    # MODIFIED 2018-09-21 -
    # Stipulate that if running on the actual management host, use it's web ssl-port value
    #
    if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
        echo | tee -a -i $APICLIlogfilepath
        echo 'Initial $APICLIwebsslport   = '$APICLIwebsslport | tee -a -i $APICLIlogfilepath
        echo 'Current $CLIparm_websslport = '$CLIparm_websslport | tee -a -i $APICLIlogfilepath
        echo 'Current $currentapisslport  = '$currentapisslport | tee -a -i $APICLIlogfilepath
    fi            

    export APICLIwebsslport=$currentapisslport

    if [ ! -z "$CLIparm_mgmt" ] ; then
        # working with remote management server
        if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
            echo 'Working with remote management server' | tee -a -i $APICLIlogfilepath
        fi            
        
        if [ ! -z "$CLIparm_websslport" ] ; then
            if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
                echo 'Working with web ssl-port from CLI parms' | tee -a -i $APICLIlogfilepath
            fi            
            export APICLIwebsslport=$CLIparm_websslport
        else
            # Default back to expected SSL port, since we won't know what the remote management server configuration for web ssl-port is.
            # This may change once Gaia API is readily available and can be checked.
            if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
                echo 'Remote management cannot currently be queried for web ssl-port, so defaulting to 443' | tee -a -i $APICLIlogfilepath
            fi            
            export APICLIwebsslport=443
        fi
    else
        # not working with remote management server
        if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
            echo 'Not working with remote management server' | tee -a -i $APICLIlogfilepath
        fi            
        
        if [ ! -z "$CLIparm_websslport" ] ; then
            if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
                echo 'Working with web ssl-port from CLI parms' | tee -a -i $APICLIlogfilepath
            fi            
            export APICLIwebsslport=$CLIparm_websslport
        else
            if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
                echo 'Working with web ssl-port harvested from Gaia' | tee -a -i $APICLIlogfilepath
            fi            
            export APICLIwebsslport=$currentapisslport
        fi
    fi

    if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
        echo 'Final $APICLIwebsslport     = '$APICLIwebsslport | tee -a -i $APICLIlogfilepath
        echo | tee -a -i $APICLIlogfilepath
    fi            
    
    # MODIFIED 2018-05-03 -

    # ================================================================================================
    # NOTE:  APICLIadmin value must be set to operate this script, removing this varaiable will lead
    #        to logon failure with mgmt_cli logon.  Root User (-r) parameter is handled differently,
    #        so DO NOT REMOVE OR CLEAR this variable.  Adjust the export APICLIadmin= line to reflect
    #        the default administrator name for the environment
    #
    #        The value for APICLIadmin now is set by the value of DefaultMgmtAdmin found at the top 
    #        of the script in the 'Root script declarations' section.
    #
    # ================================================================================================
    if [ ! -z "$CLIparm_user" ] ; then
        export APICLIadmin=$CLIparm_user
    elif [ ! -z "$DefaultMgmtAdmin" ] ; then
        export APICLIadmin=$DefaultMgmtAdmin
    else
        #export APICLIadmin=administrator
        #export APICLIadmin=admin
        export APICLIadmin=$DefaultMgmtAdmin
    fi
    
    # Clear variables that need to be set later
    
    export mgmttarget=
    export domaintarget=
    
    return 0
}

#
# \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/-  MODIFIED 2018-09-21

# -------------------------------------------------------------------------------------------------
# Login2MgmtCLI - Process Login to Management CLI
# -------------------------------------------------------------------------------------------------

# MODIFIED 2018-05-04 -\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
#

Login2MgmtCLI () {
    #
    # Execute the mgmt_cli login and address results
    #

    HandleMgmtCLILogin
    SUBEXITCODE=$?
    
    if [ "$SUBEXITCODE" != "0" ] ; then
    
        echo | tee -a -i $APICLIlogfilepath
        echo "Terminating script..." | tee -a -i $APICLIlogfilepath
        echo "Exitcode $SUBEXITCODE" | tee -a -i $APICLIlogfilepath
        echo | tee -a -i $APICLIlogfilepath
        echo | tee -a -i $APICLIlogfilepath
        echo "Log output in file $APICLIlogfilepath" | tee -a -i $APICLIlogfilepath
        echo | tee -a -i $APICLIlogfilepath
        return $SUBEXITCODE
    
    else
        echo | tee -a -i $APICLIlogfilepath
    fi
    
    return 0
}

#
# \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/-  MODIFIED 2018-05-04

# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------

# =================================================================================================
# END:  Setup Login Parameters and Mgmt_CLI handler procedures
# =================================================================================================
# =================================================================================================

# =================================================================================================
# =================================================================================================
# START:  Setup CLI Parameter based values
# =================================================================================================

# =================================================================================================
# START:  Common Procedures
# -------------------------------------------------------------------------------------------------

# MODIFIED 2018-05-03 -

# -------------------------------------------------------------------------------------------------
# ConfigureRootPath - Configure root and base path
# -------------------------------------------------------------------------------------------------

# MODIFIED 2018-05-04 -

ConfigureRootPath () {

    # ---------------------------------------------------------
    # Create the base path and directory structure for output
    # ---------------------------------------------------------
    
    export APICLIpathroot=./dump
    if [ x"$CLIparm_outputpath" != x"" ] ; then
        export APICLIpathroot=$CLIparm_outputpath
    else
        export APICLIpathroot=./dump
    fi
    
    if [ ! -r $APICLIpathroot ] ; then
        mkdir -p -v $APICLIpathroot | tee -a -i $APICLIlogfilepath
    fi
    
    export APICLIpathbase=$APICLIpathroot/$DATE
    
    if [ ! -r $APICLIpathbase ] ; then
        mkdir -p -v $APICLIpathbase | tee -a -i $APICLIlogfilepath
    fi
    
}


# -------------------------------------------------------------------------------------------------
# ConfigureLogPath - Configure log file path and handle temporary log file
# -------------------------------------------------------------------------------------------------

# MODIFIED 2018-05-04 -

ConfigureLogPath () {

    # ---------------------------------------------------------
    # Create the base path and directory structure for logging
    # ---------------------------------------------------------
    
    if [ x"$CLIparm_logpath" != x"" ] ; then
        export APICLIlogpathroot=$CLIparm_logpath
    else
        export APICLIlogpathroot=$APICLIpathroot
    fi
    
    if [ ! -r $APICLIlogpathroot ] ; then
        mkdir -p -v $APICLIlogpathroot | tee -a -i $APICLIlogfilepath
    fi
    
    export APICLIlogpathbase=$APICLIlogpathroot/$DATE
    
    if [ ! -r $APICLIlogpathbase ] ; then
        mkdir -p -v $APICLIlogpathbase | tee -a -i $APICLIlogfilepath
    fi
    
    export APICLIlogfilepathtemp=$APICLIlogfilepath
    export APICLIlogfilepath=$APICLIlogpathbase/$ScriptName'_'$APIScriptVersion'_'$DATEDTGS.log
    
    cat $APICLIlogfilepathtemp >> $APICLIlogfilepath
    rm $APICLIlogfilepathtemp | tee -a -i $APICLIlogfilepath
    
}


# -------------------------------------------------------------------------------------------------
# ConfigureCommonCLIParameterValues - Configure Common CLI Parameter Values
# -------------------------------------------------------------------------------------------------

ConfigureCommonCLIParameterValues () {

    #
    # Configure Common CLI Parameter Values
    #
    
    ConfigureRootPath

    ConfigureLogPath
    
    return 0
}

# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------

# -------------------------------------------------------------------------------------------------
# END:  Common Procedures
# =================================================================================================

# =================================================================================================
# START:  Specific Procedures
# -------------------------------------------------------------------------------------------------

# MODIFIED 2018-05-03 -

# -------------------------------------------------------------------------------------------------
# ConfigureOtherCLIParameterPaths - Configure other path and folder values based on CLI parameters
# -------------------------------------------------------------------------------------------------

ConfigureOtherCLIParameterPaths () {

    # ---------------------------------------------------------
    # Setup other paths we may need - but these should not create folders (yet)
    # Configure other path and folder values based on CLI parameters
    # ---------------------------------------------------------
    
    export APICLICSVExportpathbase=
    if [ x"$script_use_export" = x"true" ] ; then
        if [ x"$CLIparm_exportpath" != x"" ] ; then
            export APICLICSVExportpathbase=$CLIparm_exportpath
        else
            export APICLICSVExportpathbase=$APICLIpathbase
        fi
    fi
    
    export APICLICSVImportpathbase=
    if [ x"$script_use_import" = x"true" ] ; then
        if [ x"$CLIparm_importpath" != x"" ] ; then
            export APICLICSVImportpathbase=$CLIparm_importpath
        else
            export APICLICSVImportpathbase=./import.csv
        fi
    fi
    
    export APICLICSVDeletepathbase=
    if [ x"$script_use_delete" = x"true" ] ; then
        if [ x"$CLIparm_deletepath" != x"" ] ; then
            export APICLICSVDeletepathbase=$CLIparm_deletepath
        else
            export APICLICSVDeletepathbase=./delete.csv
        fi
    fi
    
    export APICLICSVcsvpath=
    if [ x"$script_use_csvfile" = x"true" ] ; then
        if [ x"$CLIparm_csvpath" != x"" ] ; then
            export APICLICSVcsvpath=$CLIparm_csvpath
        else
            export APICLICSVcsvpath=./domains.csv
        fi
    fi
    return 0
}

# -------------------------------------------------------------------------------------------------
# ConfigureOtherCLIParameterValues - Configure other values based on CLI parameters
# -------------------------------------------------------------------------------------------------

ConfigureOtherCLIParameterValues () {

    # ---------------------------------------------------------
    # Setup other variables based on CLI parameters
    # ---------------------------------------------------------
    
#    export NoSystemObjects=false
    export NoSystemObjects=true
    
    export NoSystemObjectsValue=`echo "$CLIparm_NoSystemObjects" | tr '[:upper:]' '[:lower:]'`
    
#    if [ x"$NoSystemObjectsValue" = x"true" ] ; then
#        export NoSystemObjects=true
#    else
#        export NoSystemObjects=false
#    fi
    
    if [ x"$NoSystemObjectsValue" = x"false" ] ; then
        export NoSystemObjects=false
    else
        export NoSystemObjects=true
    fi
    
    return 0
}


# -------------------------------------------------------------------------------------------------
# ConfigureSpecificCLIParameterValues - Configure Specific CLI Parameter Values
# -------------------------------------------------------------------------------------------------

ConfigureSpecificCLIParameterValues () {

    #
    # Configure Specific CLI Parameter Values
    #
    
    ConfigureOtherCLIParameterPaths

    ConfigureOtherCLIParameterValues

    return 0
}

# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------

# -------------------------------------------------------------------------------------------------
# END:  Specific Procedures
# =================================================================================================

# -------------------------------------------------------------------------------------------------
# Set parameters for Main operations - CLI
# -------------------------------------------------------------------------------------------------

ConfigureCommonCLIParameterValues

ConfigureSpecificCLIParameterValues
    
# =================================================================================================
# END:  Setup CLI Parameter based values
# =================================================================================================
# =================================================================================================


# =================================================================================================
# -------------------------------------------------------------------------------------------------
# =================================================================================================
# START:  Main operations - 
# =================================================================================================


# -------------------------------------------------------------------------------------------------
# Set parameters for Main operations - Other Path Values
# -------------------------------------------------------------------------------------------------

if [ "$script_dump_csv" = "true" ] ; then
    export APICLIdumppathcsv=$APICLICSVExportpathbase/csv
fi

if [ x"$script_dump_json" = x"true" ] ; then
    export APICLIdumppathjson=$APICLICSVExportpathbase/json
fi

if [ x"$script_dump_full" = x"true" ] ; then
    export APICLIdumppathjsonfull=$APICLIdumppathjson/full
fi

if [ x"$script_dump_standard" = x"true" ] ; then
    export APICLIdumppathjsonstandard=$APICLIdumppathjson/standard
fi


# =================================================================================================
# START:  Setup Login Parameters and Login to Mgmt_CLI
# =================================================================================================

# MODIFIED 2018-09-21 -\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
#

SetupLogin2MgmtCLI

if [ ! -z "$CLIparm_domain" ] ; then
    # Handle domain parameter for login string
    if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
        echo 'Command line parameter for domain set!  Domain = '$CLIparm_domain | tee -a -i $APICLIlogfilepath
    fi
    export domaintarget=$CLIparm_domain
else
    if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
        echo 'Command line parameter for domain NOT set!' | tee -a -i $APICLIlogfilepath
    fi
    export domaintarget=
fi

if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
    echo "domaintarget = '$domaintarget' " | tee -a -i $APICLIlogfilepath
fi

Login2MgmtCLI
LOGINEXITCODE=$?

export LoggedIntoMgmtCli=false

if [ "$LOGINEXITCODE" != "0" ] ; then
    exit $LOGINEXITCODE
else
    export LoggedIntoMgmtCli=true
fi

#
# \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/-  MODIFIED 2018-09-21


# =================================================================================================
# START:  Get objects Totals
# =================================================================================================


export APICLIdetaillvl=standard

#export APICLIdetaillvl=full

# ADDED 2018-05-04-2 -
# Only changes this parameter to force the specific state of CLIparm_NoSystemObjects
# since it is set using the command line parameters --SO (false) and --NSO (true)
#
#export CLIparm_NoSystemObjects=false

# ADDED 2018-04-25 -
export primarytargetoutputformat=$FileExtTXT

# -------------------------------------------------------------------------------------------------
# Start executing Main operations
# -------------------------------------------------------------------------------------------------

# -------------------------------------------------------------------------------------------------
# Configure working paths for export and dump
# -------------------------------------------------------------------------------------------------

# MODIFIED 2018-05-04-3 \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
#

# ------------------------------------------------------------------------
# Set and clear temporary log file
# ------------------------------------------------------------------------

export templogfilepath=/var/tmp/templog_$ScriptName.`date +%Y%m%d-%H%M%S%Z`.log
echo > $templogfilepath

echo 'Configure working paths for export and dump' >> $templogfilepath
echo >> $templogfilepath

echo "domainnamenospace = '$domainnamenospace' " >> $templogfilepath
echo "CLIparm_NODOMAINFOLDERS = '$CLIparm_NODOMAINFOLDERS' " >> $templogfilepath
echo "primarytargetoutputformat = '$primarytargetoutputformat' " >> $templogfilepath
echo "APICLICSVExportpathbase = '$APICLICSVExportpathbase' " >> $templogfilepath
echo "APICLIpathexport = '$APICLIpathexport' " >> $templogfilepath

# ------------------------------------------------------------------------

if [ ! -z "$domainnamenospace" ] && [ "$CLIparm_NODOMAINFOLDERS" != "true" ] ; then
    # Handle adding domain name to path for MDM operations
    export APICLIpathexport=$APICLICSVExportpathbase/$domainnamenospace

    echo 'Handle adding domain name to path for MDM operations' >> $templogfilepath
    echo "APICLIpathexport = '$APICLIpathexport' " >> $templogfilepath

    if [ ! -r $APICLIpathexport ] ; then
        mkdir -p -v $APICLIpathexport >> $templogfilepath
    fi
else
    # NOT adding domain name to path for MDM operations
    export APICLIpathexport=$APICLICSVExportpathbase

    echo 'NOT adding domain name to path for MDM operations' >> $templogfilepath
    echo "APICLIpathexport = '$APICLIpathexport' " >> $templogfilepath

    if [ ! -r $APICLIpathexport ] ; then
        mkdir -p -v $APICLIpathexport >> $templogfilepath
    fi
fi

# ------------------------------------------------------------------------

if [ x"$script_use_delete" = x"true" ] ; then
    # primary operation is delete

    export APICLIpathexport=$APICLIpathexport/delete

    echo | tee -a -i $APICLIlogfilepath $templogfilepath
    echo 'Delete using '$primarytargetoutputformat' Starting!' | tee -a -i $APICLIlogfilepath $templogfilepath
    
elif [ x"$script_use_import" = x"true" ] ; then
    # primary operation is import

    export APICLIpathexport=$APICLIpathexport/import

    echo | tee -a -i $APICLIlogfilepath $templogfilepath
    echo 'Import using '$primarytargetoutputformat' Starting!' | tee -a -i $APICLIlogfilepath $templogfilepath
    
elif [ x"$script_use_export" = x"true" ] ; then
    # primary operation is export

    # primary operation is export to primarytargetoutputformat
    export APICLIpathexport=$APICLIpathexport/$primarytargetoutputformat

    echo | tee -a -i $APICLIlogfilepath $templogfilepath
    echo 'Export to '$primarytargetoutputformat' Starting!' | tee -a -i $APICLIlogfilepath $templogfilepath
    
else
    # primary operation is something else

    export APICLIpathexport=$APICLIpathbase

fi

if [ ! -r $APICLIpathexport ] ; then
    mkdir -p -v $APICLIpathexport >> $templogfilepath
fi

echo >> $templogfilepath
echo 'After Evaluation of script type' >> $templogfilepath
echo "APICLIpathexport = '$APICLIpathexport' " >> $templogfilepath
echo " = '$' " >> $templogfilepath

# ------------------------------------------------------------------------

if [ x"$primarytargetoutputformat" = x"$FileExtJSON" ] ; then
    # for JSON provide the detail level

    export APICLIpathexport=$APICLIpathexport/$APICLIdetaillvl

    if [ ! -r $APICLIpathexport ] ; then
        mkdir -p -v $APICLIpathexport >> $templogfilepath
    fi

    export APICLIJSONpathexportwip=
    if [ x"$script_uses_wip_json" = x"true" ] ; then
        # script uses work-in-progress (wip) folder for json
    
        export APICLIJSONpathexportwip=$APICLIpathexport/wip
        
        if [ ! -r $APICLIJSONpathexportwip ] ; then
            mkdir -p -v $APICLIJSONpathexportwip >> $templogfilepath
        fi
    fi
else    
    export APICLIJSONpathexportwip=
fi

echo >> $templogfilepath
echo 'After handling json target' >> $templogfilepath
echo "APICLIpathexport = '$APICLIpathexport' " >> $templogfilepath
echo "APICLIJSONpathexportwip = '$APICLIJSONpathexportwip' " >> $templogfilepath

# ------------------------------------------------------------------------

if [ x"$primarytargetoutputformat" = x"$FileExtCSV" ] ; then
    # for CSV handle specifics, like wip

    export APICLICSVpathexportwip=
    if [ x"$script_uses_wip" = x"true" ] ; then
        # script uses work-in-progress (wip) folder for csv
    
        export APICLICSVpathexportwip=$APICLIpathexport/wip
        
        if [ ! -r $APICLICSVpathexportwip ] ; then
            mkdir -p -v $APICLICSVpathexportwip >> $templogfilepath
        fi
    fi
else
    export APICLICSVpathexportwip=
fi

echo >> $templogfilepath
echo 'After handling csv target' >> $templogfilepath
echo "APICLIpathexport = '$APICLIpathexport' " >> $templogfilepath
echo "APICLICSVpathexportwip = '$APICLICSVpathexportwip' " >> $templogfilepath

# ------------------------------------------------------------------------

export APICLIfileexportpost='_'$APICLIdetaillvl'_'$APICLIfileexportsuffix

export APICLICSVheaderfilesuffix=header

export APICLICSVfileexportpost='_'$APICLIdetaillvl'_'$APICLICSVfileexportsuffix

export APICLIJSONheaderfilesuffix=header
export APICLIJSONfooterfilesuffix=footer

export APICLIJSONfileexportpost='_'$APICLIdetaillvl'_'$APICLIJSONfileexportsuffix

echo >> $templogfilepath
echo 'Setup other file and path variables' >> $templogfilepath
echo "APICLIfileexportpost = '$APICLIfileexportpost' " >> $templogfilepath
echo "APICLICSVheaderfilesuffix = '$APICLICSVheaderfilesuffix' " >> $templogfilepath
echo "APICLICSVfileexportpost = '$APICLICSVfileexportpost' " >> $templogfilepath
echo "APICLIJSONheaderfilesuffix = '$APICLIJSONheaderfilesuffix' " >> $templogfilepath
echo "APICLIJSONfooterfilesuffix = '$APICLIJSONfooterfilesuffix' " >> $templogfilepath
echo "APICLIJSONfileexportpost = '$APICLIJSONfileexportpost' " >> $templogfilepath

# ------------------------------------------------------------------------

echo >> $templogfilepath

cat $templogfilepath >> $APICLIlogfilepath
rm -v $templogfilepath >> $APICLIlogfilepath

# ------------------------------------------------------------------------

echo 'Dump "'$APICLIdetaillvl'" details to path:  '$APICLIpathexport | tee -a -i $APICLIlogfilepath
echo | tee -a -i $APICLIlogfilepath

#
# /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\ MODIFIED 2018-05-04-3


echo
echo 'Get Object totals : ' | tee -a -i $APICLIlogfilepath
echo


# -------------------------------------------------------------------------------------------------
# Main Operational repeated proceedure - ExportObjectsToCSVviaJQ
# -------------------------------------------------------------------------------------------------

# -------------------------------------------------------------------------------------------------
# GetNumberOfObjectsviaJQ
# -------------------------------------------------------------------------------------------------

# MODIFIED 2018-05-04 \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
#

GetNumberOfObjectsviaJQ () {
    #
    # The GetNumberOfObjectsviaJQ obtains the number of objects for that object type indicated.
    #
    
    export objectstotal=
    
    #
    # Troubleshooting output
    #
    if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
        # Verbose mode ON
        echo | tee -a -i $APICLIlogfilepath
        echo 'Get objectstotal of object type '$APICLIobjectstype | tee -a -i $APICLIlogfilepath
        echo | tee -a -i $APICLIlogfilepath
    fi
    
    objectstotal=$(mgmt_cli show $APICLIobjectstype limit 1 offset 0 details-level "standard" -f json -s $APICLIsessionfile | $JQ ".total")
    errorreturn=$?

    if [ $errorreturn != 0 ] ; then
        # Something went wrong, terminate
        echo 'Problem during mgmt_cli objectstotal operation! error return = '$errorreturn | tee -a -i $APICLIlogfilepath
        return $errorreturn
    fi
    
    export number_of_objects=$objectstotal

    echo | tee -a -i $APICLIlogfilepath
    return 0
    
    #
}

#
# /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\ MODIFIED 2018-05-04

# -------------------------------------------------------------------------------------------------


# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------


# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------
# handle simple objects
# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------

# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------
# Objects
# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------

echo
echo 'Objects'
echo
echo >> $APICLIlogfilepath
echo 'Objects' >> $APICLIlogfilepath
echo >> $APICLIlogfilepath

# -------------------------------------------------------------------------------------------------
# hosts
# -------------------------------------------------------------------------------------------------

export APICLIobjecttype=host
export APICLIobjectstype=hosts
export APICLIexportnameaddon=

objectstotal_hosts=$(mgmt_cli show $APICLIobjectstype limit 1 offset 0 details-level "standard" -f json -s $APICLIsessionfile | $JQ ".total")
export number_hosts="$objectstotal_hosts"
export number_of_objects=$number_hosts

echo 'Number of '$APICLIobjecttype' Objects is = '$number_of_objects' '$APICLIobjectstype
echo 'Number of '$APICLIobjecttype' Objects is = '$number_of_objects' '$APICLIobjectstype >> $APICLIlogfilepath

# -------------------------------------------------------------------------------------------------
# networks
# -------------------------------------------------------------------------------------------------

export APICLIobjecttype=network
export APICLIobjectstype=networks
export APICLIexportnameaddon=

objectstotal_networks=$(mgmt_cli show $APICLIobjectstype limit 1 offset 0 details-level "standard" -f json -s $APICLIsessionfile | $JQ ".total")
export number_networks="$objectstotal_networks"
export number_of_objects=$number_networks

echo 'Number of '$APICLIobjecttype' Objects is = '$number_of_objects' '$APICLIobjectstype
echo 'Number of '$APICLIobjecttype' Objects is = '$number_of_objects' '$APICLIobjectstype >> $APICLIlogfilepath


# -------------------------------------------------------------------------------------------------
# groups
# -------------------------------------------------------------------------------------------------

export APICLIobjecttype=group
export APICLIobjectstype=groups
export APICLIexportnameaddon=

objectstotal_groups=$(mgmt_cli show $APICLIobjectstype limit 1 offset 0 details-level "standard" -f json -s $APICLIsessionfile | $JQ ".total")
export number_groups="$objectstotal_groups"
export number_of_objects=$number_groups

echo 'Number of '$APICLIobjecttype' Objects is = '$number_of_objects' '$APICLIobjectstype
echo 'Number of '$APICLIobjecttype' Objects is = '$number_of_objects' '$APICLIobjectstype >> $APICLIlogfilepath


# -------------------------------------------------------------------------------------------------
# groups-with-exclusion
# -------------------------------------------------------------------------------------------------

export APICLIobjecttype=group-with-exclusion
export APICLIobjectstype=groups-with-exclusion
export APICLIexportnameaddon=

objectstotal_groupswithexclusion=$(mgmt_cli show $APICLIobjectstype limit 1 offset 0 details-level "standard" -f json -s $APICLIsessionfile | $JQ ".total")
export number_groupswithexclusion="$objectstotal_groupswithexclusion"
export number_of_objects=$number_groupswithexclusion

echo 'Number of '$APICLIobjecttype' Objects is = '$number_of_objects' '$APICLIobjectstype
echo 'Number of '$APICLIobjecttype' Objects is = '$number_of_objects' '$APICLIobjectstype >> $APICLIlogfilepath


# -------------------------------------------------------------------------------------------------
# address-ranges
# -------------------------------------------------------------------------------------------------

export APICLIobjecttype=address-range
export APICLIobjectstype=address-ranges
export APICLIexportnameaddon=

objectstotal_addressranges=$(mgmt_cli show $APICLIobjectstype limit 1 offset 0 details-level "standard" -f json -s $APICLIsessionfile | $JQ ".total")
export number_addressranges="$objectstotal_addressranges"
export number_of_objects=$number_addressranges

echo 'Number of '$APICLIobjecttype' Objects is = '$number_of_objects' '$APICLIobjectstype
echo 'Number of '$APICLIobjecttype' Objects is = '$number_of_objects' '$APICLIobjectstype >> $APICLIlogfilepath


# -------------------------------------------------------------------------------------------------
# multicast-address-ranges
# -------------------------------------------------------------------------------------------------

export APICLIobjecttype=multicast-address-range
export APICLIobjectstype=multicast-address-ranges
export APICLIexportnameaddon=

objectstotal_multicastaddressranges=$(mgmt_cli show $APICLIobjectstype limit 1 offset 0 details-level "standard" -f json -s $APICLIsessionfile | $JQ ".total")
export number_multicastaddressranges="$objectstotal_multicastaddressranges"
export number_of_objects=$number_multicastaddressranges

echo 'Number of '$APICLIobjecttype' Objects is = '$number_of_objects' '$APICLIobjectstype
echo 'Number of '$APICLIobjecttype' Objects is = '$number_of_objects' '$APICLIobjectstype >> $APICLIlogfilepath


# -------------------------------------------------------------------------------------------------
# dns-domains
# -------------------------------------------------------------------------------------------------

export APICLIobjecttype=dns-domain
export APICLIobjectstype=dns-domains
export APICLIexportnameaddon=

objectstotal_dnsdomains=$(mgmt_cli show $APICLIobjectstype limit 1 offset 0 details-level "standard" -f json -s $APICLIsessionfile | $JQ ".total")
export number_dnsdomains="$objectstotal_dnsdomains"
export number_of_objects=$number_dnsdomains

echo 'Number of '$APICLIobjecttype' Objects is = '$number_of_objects' '$APICLIobjectstype
echo 'Number of '$APICLIobjecttype' Objects is = '$number_of_objects' '$APICLIobjectstype >> $APICLIlogfilepath


# -------------------------------------------------------------------------------------------------
# security-zones
# -------------------------------------------------------------------------------------------------

export APICLIobjecttype=security-zone
export APICLIobjectstype=security-zones
export APICLIexportnameaddon=

objectstotal_securityzones=$(mgmt_cli show $APICLIobjectstype limit 1 offset 0 details-level "standard" -f json -s $APICLIsessionfile | $JQ ".total")
export number_securityzones="$objectstotal_securityzones"
export number_of_objects=$number_securityzones

echo 'Number of '$APICLIobjecttype' Objects is = '$number_of_objects' '$APICLIobjectstype
echo 'Number of '$APICLIobjecttype' Objects is = '$number_of_objects' '$APICLIobjectstype >> $APICLIlogfilepath


# -------------------------------------------------------------------------------------------------
# dynamic-objects
# -------------------------------------------------------------------------------------------------

export APICLIobjecttype=dynamic-object
export APICLIobjectstype=dynamic-objects
export APICLIexportnameaddon=

objectstotal_dynamicobjects=$(mgmt_cli show $APICLIobjectstype limit 1 offset 0 details-level "standard" -f json -s $APICLIsessionfile | $JQ ".total")
export number_dynamicobjects="$objectstotal_dynamicobjects"
export number_of_objects=$number_dynamicobjects

echo 'Number of '$APICLIobjecttype' Objects is = '$number_of_objects' '$APICLIobjectstype
echo 'Number of '$APICLIobjecttype' Objects is = '$number_of_objects' '$APICLIobjectstype >> $APICLIlogfilepath


# -------------------------------------------------------------------------------------------------
# simple-gateways
# -------------------------------------------------------------------------------------------------

export APICLIobjecttype=simple-gateway
export APICLIobjectstype=simple-gateways
export APICLIexportnameaddon=

objectstotal_simplegateways=$(mgmt_cli show $APICLIobjectstype limit 1 offset 0 details-level "standard" -f json -s $APICLIsessionfile | $JQ ".total")
export number_simplegateways="$objectstotal_simplegateways"
export number_of_objects=$number_simplegateways

echo 'Number of '$APICLIobjecttype' Objects is = '$number_of_objects' '$APICLIobjectstype
echo 'Number of '$APICLIobjecttype' Objects is = '$number_of_objects' '$APICLIobjectstype >> $APICLIlogfilepath


# -------------------------------------------------------------------------------------------------
# times
# -------------------------------------------------------------------------------------------------

export APICLIobjecttype=time
export APICLIobjectstype=times
export APICLIexportnameaddon=

objectstotal_times=$(mgmt_cli show $APICLIobjectstype limit 1 offset 0 details-level "standard" -f json -s $APICLIsessionfile | $JQ ".total")
export number_times="$objectstotal_times"
export number_of_objects=$number_times

echo 'Number of '$APICLIobjecttype' Objects is = '$number_of_objects' '$APICLIobjectstype
echo 'Number of '$APICLIobjecttype' Objects is = '$number_of_objects' '$APICLIobjectstype >> $APICLIlogfilepath


# -------------------------------------------------------------------------------------------------
# time_groups
# -------------------------------------------------------------------------------------------------

export APICLIobjecttype=time-group
export APICLIobjectstype=time-groups
export APICLIexportnameaddon=

objectstotal_time_groups=$(mgmt_cli show $APICLIobjectstype limit 1 offset 0 details-level "standard" -f json -s $APICLIsessionfile | $JQ ".total")
export number_time_groups="$objectstotal_time_groups"
export number_of_objects=$number_time_groups

echo 'Number of '$APICLIobjecttype' Objects is = '$number_of_objects' '$APICLIobjectstype
echo 'Number of '$APICLIobjecttype' Objects is = '$number_of_objects' '$APICLIobjectstype >> $APICLIlogfilepath


# -------------------------------------------------------------------------------------------------
# access-roles
# -------------------------------------------------------------------------------------------------

export APICLIobjecttype=access-role
export APICLIobjectstype=access-roles
export APICLIexportnameaddon=

objectstotal_access_roles=$(mgmt_cli show $APICLIobjectstype limit 1 offset 0 details-level "standard" -f json -s $APICLIsessionfile | $JQ ".total")
export number_access_roles="$objectstotal_access_roles"
export number_of_objects=$number_access_roles

echo 'Number of '$APICLIobjecttype' Objects is = '$number_of_objects' '$APICLIobjectstype
echo 'Number of '$APICLIobjecttype' Objects is = '$number_of_objects' '$APICLIobjectstype >> $APICLIlogfilepath


# -------------------------------------------------------------------------------------------------
# opsec-applications
# -------------------------------------------------------------------------------------------------

export APICLIobjecttype=opsec-application
export APICLIobjectstype=opsec-applications
export APICLIexportnameaddon=

objectstotal_opsec_applications=$(mgmt_cli show $APICLIobjectstype limit 1 offset 0 details-level "standard" -f json -s $APICLIsessionfile | $JQ ".total")
export number_opsec_applications="$objectstotal_opsec_applications"
export number_of_objects=$number_opsec_applications

echo 'Number of '$APICLIobjecttype' Objects is = '$number_of_objects' '$APICLIobjectstype
echo 'Number of '$APICLIobjecttype' Objects is = '$number_of_objects' '$APICLIobjectstype >> $APICLIlogfilepath


# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------
# Services and Applications
# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------

echo
echo 'Services and Applications'
echo
echo >> $APICLIlogfilepath
echo 'Services and Applications' >> $APICLIlogfilepath
echo >> $APICLIlogfilepath

# -------------------------------------------------------------------------------------------------
# services-tcp objects
# -------------------------------------------------------------------------------------------------

export APICLIobjecttype=service-tcp
export APICLIobjectstype=services-tcp
export APICLIexportnameaddon=

objectstotal_services_tcp=$(mgmt_cli show $APICLIobjectstype limit 1 offset 0 details-level "standard" -f json -s $APICLIsessionfile | $JQ ".total")
export number_services_tcp="$objectstotal_services_tcp"
export number_of_objects=$number_services_tcp

echo 'Number of '$APICLIobjecttype' Objects is = '$number_of_objects' '$APICLIobjectstype
echo 'Number of '$APICLIobjecttype' Objects is = '$number_of_objects' '$APICLIobjectstype >> $APICLIlogfilepath


# -------------------------------------------------------------------------------------------------
# services-udp objects
# -------------------------------------------------------------------------------------------------

export APICLIobjecttype=service-udp
export APICLIobjectstype=services-udp
export APICLIexportnameaddon=

objectstotal_services_udp=$(mgmt_cli show $APICLIobjectstype limit 1 offset 0 details-level "standard" -f json -s $APICLIsessionfile | $JQ ".total")
export number_services_udp="$objectstotal_services_udp"
export number_of_objects=$number_services_udp

echo 'Number of '$APICLIobjecttype' Objects is = '$number_of_objects' '$APICLIobjectstype
echo 'Number of '$APICLIobjecttype' Objects is = '$number_of_objects' '$APICLIobjectstype >> $APICLIlogfilepath


# -------------------------------------------------------------------------------------------------
# services-icmp objects
# -------------------------------------------------------------------------------------------------

export APICLIobjecttype=service-icmp
export APICLIobjectstype=services-icmp
export APICLIexportnameaddon=

objectstotal_services_icmp=$(mgmt_cli show $APICLIobjectstype limit 1 offset 0 details-level "standard" -f json -s $APICLIsessionfile | $JQ ".total")
export number_services_icmp="$objectstotal_services_icmp"
export number_of_objects=$number_services_icmp

echo 'Number of '$APICLIobjecttype' Objects is = '$number_of_objects' '$APICLIobjectstype
echo 'Number of '$APICLIobjecttype' Objects is = '$number_of_objects' '$APICLIobjectstype >> $APICLIlogfilepath


# -------------------------------------------------------------------------------------------------
# services-icmp6 objects
# -------------------------------------------------------------------------------------------------

export APICLIobjecttype=service-icmp6
export APICLIobjectstype=services-icmp6
export APICLIexportnameaddon=

objectstotal_services_icmp6=$(mgmt_cli show $APICLIobjectstype limit 1 offset 0 details-level "standard" -f json -s $APICLIsessionfile | $JQ ".total")
export number_services_icmp6="$objectstotal_services_icmp6"
export number_of_objects=$number_services_icmp6

echo 'Number of '$APICLIobjecttype' Objects is = '$number_of_objects' '$APICLIobjectstype
echo 'Number of '$APICLIobjecttype' Objects is = '$number_of_objects' '$APICLIobjectstype >> $APICLIlogfilepath


# -------------------------------------------------------------------------------------------------
# services-sctp objects
# -------------------------------------------------------------------------------------------------

export APICLIobjecttype=service-sctp
export APICLIobjectstype=services-sctp
export APICLIexportnameaddon=

objectstotal_services_sctp=$(mgmt_cli show $APICLIobjectstype limit 1 offset 0 details-level "standard" -f json -s $APICLIsessionfile | $JQ ".total")
export number_services_sctp="$objectstotal_services_sctp"
export number_of_objects=$number_services_sctp

echo 'Number of '$APICLIobjecttype' Objects is = '$number_of_objects' '$APICLIobjectstype
echo 'Number of '$APICLIobjecttype' Objects is = '$number_of_objects' '$APICLIobjectstype >> $APICLIlogfilepath


# -------------------------------------------------------------------------------------------------
# services-other objects
# -------------------------------------------------------------------------------------------------

export APICLIobjecttype=service-other
export APICLIobjectstype=services-other
export APICLIexportnameaddon=

objectstotal_services_other=$(mgmt_cli show $APICLIobjectstype limit 1 offset 0 details-level "standard" -f json -s $APICLIsessionfile | $JQ ".total")
export number_services_other="$objectstotal_services_other"
export number_of_objects=$number_services_other

echo 'Number of '$APICLIobjecttype' Objects is = '$number_of_objects' '$APICLIobjectstype
echo 'Number of '$APICLIobjecttype' Objects is = '$number_of_objects' '$APICLIobjectstype >> $APICLIlogfilepath


# -------------------------------------------------------------------------------------------------
# services-dce-rpc objects
# -------------------------------------------------------------------------------------------------

export APICLIobjecttype=service-dce-rpc
export APICLIobjectstype=services-dce-rpc
export APICLIexportnameaddon=

objectstotal_services_dce_rpc=$(mgmt_cli show $APICLIobjectstype limit 1 offset 0 details-level "standard" -f json -s $APICLIsessionfile | $JQ ".total")
export number_services_dce_rpc="$objectstotal_services_dce_rpc"
export number_of_objects=$number_services_dce_rpc

echo 'Number of '$APICLIobjecttype' Objects is = '$number_of_objects' '$APICLIobjectstype
echo 'Number of '$APICLIobjecttype' Objects is = '$number_of_objects' '$APICLIobjectstype >> $APICLIlogfilepath


# -------------------------------------------------------------------------------------------------
# services-rpc objects
# -------------------------------------------------------------------------------------------------

export APICLIobjecttype=service-rpc
export APICLIobjectstype=services-rpc
export APICLIexportnameaddon=

objectstotal_services_rpc=$(mgmt_cli show $APICLIobjectstype limit 1 offset 0 details-level "standard" -f json -s $APICLIsessionfile | $JQ ".total")
export number_services_rpc="$objectstotal_services_rpc"
export number_of_objects=$number_services_rpc

echo 'Number of '$APICLIobjecttype' Objects is = '$number_of_objects' '$APICLIobjectstype
echo 'Number of '$APICLIobjecttype' Objects is = '$number_of_objects' '$APICLIobjectstype >> $APICLIlogfilepath


# -------------------------------------------------------------------------------------------------
# service-groups objects
# -------------------------------------------------------------------------------------------------

export APICLIobjecttype=service-group
export APICLIobjectstype=service-groups
export APICLIexportnameaddon=

objectstotal_service_groups=$(mgmt_cli show $APICLIobjectstype limit 1 offset 0 details-level "standard" -f json -s $APICLIsessionfile | $JQ ".total")
export number_service_groups="$objectstotal_service_groups"
export number_of_objects=$number_service_groups

echo 'Number of '$APICLIobjecttype' Objects is = '$number_of_objects' '$APICLIobjectstype
echo 'Number of '$APICLIobjecttype' Objects is = '$number_of_objects' '$APICLIobjectstype >> $APICLIlogfilepath


# -------------------------------------------------------------------------------------------------
# application-sites objects
# -------------------------------------------------------------------------------------------------

export APICLIobjecttype=application-sites
export APICLIobjectstype=application-sites
export APICLIexportnameaddon=

objectstotal_application_sites=$(mgmt_cli show $APICLIobjectstype limit 1 offset 0 details-level "standard" -f json -s $APICLIsessionfile | $JQ ".total")
export number_application_sites="$objectstotal_application_sites"
export number_of_objects=$number_application_sites

echo 'Number of '$APICLIobjecttype' Objects is = '$number_of_objects' '$APICLIobjectstype
echo 'Number of '$APICLIobjecttype' Objects is = '$number_of_objects' '$APICLIobjectstype >> $APICLIlogfilepath


# -------------------------------------------------------------------------------------------------
# application-site-categories objects
# -------------------------------------------------------------------------------------------------

export APICLIobjecttype=application-site-category
export APICLIobjectstype=application-site-categories
export APICLIexportnameaddon=

objectstotal_application_site_categories=$(mgmt_cli show $APICLIobjectstype limit 1 offset 0 details-level "standard" -f json -s $APICLIsessionfile | $JQ ".total")
export number_application_site_categories="$objectstotal_application_site_categories"
export number_of_objects=$number_application_site_categories

echo 'Number of '$APICLIobjecttype' Objects is = '$number_of_objects' '$APICLIobjectstype
echo 'Number of '$APICLIobjecttype' Objects is = '$number_of_objects' '$APICLIobjectstype >> $APICLIlogfilepath


# -------------------------------------------------------------------------------------------------
# application-site-groups objects
# -------------------------------------------------------------------------------------------------

export APICLIobjecttype=application-site-groups
export APICLIobjectstype=application-site-groups
export APICLIexportnameaddon=

objectstotal_application_site_groups=$(mgmt_cli show $APICLIobjectstype limit 1 offset 0 details-level "standard" -f json -s $APICLIsessionfile | $JQ ".total")
export number_application_site_groups="$objectstotal_application_site_groups"
export number_of_objects=$number_application_site_groups

echo 'Number of '$APICLIobjecttype' Objects is = '$number_of_objects' '$APICLIobjectstype
echo 'Number of '$APICLIobjecttype' Objects is = '$number_of_objects' '$APICLIobjectstype >> $APICLIlogfilepath


# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------
# Identifying Data
# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------

echo
echo 'Identifying Data'
echo

# -------------------------------------------------------------------------------------------------
# tags
# -------------------------------------------------------------------------------------------------

export APICLIobjecttype=tags
export APICLIobjectstype=tags
export APICLIexportnameaddon=

objectstotal_tags=$(mgmt_cli show $APICLIobjectstype limit 1 offset 0 details-level "standard" -f json -s $APICLIsessionfile | $JQ ".total")
export number_tags="$objectstotal_tags"
export number_of_objects=$number_tags

echo 'Number of '$APICLIobjecttype' Objects is = '$number_of_objects' '$APICLIobjectstype
echo 'Number of '$APICLIobjecttype' Objects is = '$number_of_objects' '$APICLIobjectstype >> $APICLIlogfilepath


# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------
# no more simple objects
# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------

# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------
# handle complex objects
# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------

# ADDED 2017-11-09  \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
#

# -------------------------------------------------------------------------------------------------
# SetupExportComplexObjectsToCSVviaJQ
# -------------------------------------------------------------------------------------------------

# MODIFIED 2018-05-04 \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
#

# The SetupExportComplexObjectsToCSVviaJQ is the setup actions for the script's repeated actions.
#

SetupExportComplexObjectsToCSVviaJQ () {
    #
    # Screen width template for sizing, default width of 80 characters assumed
    #
    #              1111111111222222222233333333334444444444555555555566666666667777777777888888888899999999990
    #    01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
    
    echo
    
    export APICLICSVfilename=$APICLIcomplexobjectstype'_'$APICLIdetaillvl'_csv'$APICLICSVfileexportsuffix
    export APICLICSVfile=$APICLIpathexport/$APICLICSVfilename
    export APICLICSVfilewip=$APICLICSVpathexportwip/$APICLICSVfilename
    export APICLICSVfileheader=$APICLICSVfilewip.$APICLICSVheaderfilesuffix
    export APICLICSVfiledata=$APICLICSVfilewip.data
    export APICLICSVfilesort=$APICLICSVfilewip.sort
    export APICLICSVfileoriginal=$APICLICSVfilewip.original

    
    if [ ! -r $APICLICSVpathexportwip ] ; then
        mkdir -p -v $APICLICSVpathexportwip | tee -a -i $APICLIlogfilepath
    fi

    if [ -r $APICLICSVfile ] ; then
        rm $APICLICSVfile >> $APICLIlogfilepath
    fi
    if [ -r $APICLICSVfileheader ] ; then
        rm $APICLICSVfileheader >> $APICLIlogfilepath
    fi
    if [ -r $APICLICSVfiledata ] ; then
        rm $APICLICSVfiledata >> $APICLIlogfilepath
    fi
    if [ -r $APICLICSVfilesort ] ; then
        rm $APICLICSVfilesort >> $APICLIlogfilepath
    fi
    if [ -r $APICLICSVfileoriginal ] ; then
        rm $APICLICSVfileoriginal >> $APICLIlogfilepath
    fi
    
    echo | tee -a -i $APICLIlogfilepath
    echo "Creat $APICLIcomplexobjectstype CSV File : $APICLICSVfile" | tee -a -i $APICLIlogfilepath
    echo | tee -a -i $APICLIlogfilepath
    
    #
    # Troubleshooting output
    #
    if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
        # Verbose mode ON
        echo | tee -a -i $APICLIlogfilepath
        echo '$CSVFileHeader' - $CSVFileHeader | tee -a -i $APICLIlogfilepath
        echo | tee -a -i $APICLIlogfilepath
    
    fi
    
    echo $CSVFileHeader > $APICLICSVfileheader | tee -a -i $APICLIlogfilepath
    echo | tee -a -i $APICLIlogfilepath
    
    echo | tee -a -i $APICLIlogfilepath
    return 0
    
    #
}


# -------------------------------------------------------------------------------------------------

#
# /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\ MODIFIED 2018-05-04

# -------------------------------------------------------------------------------------------------
# FinalizeExportComplexObjectsToCSVviaJQ
# -------------------------------------------------------------------------------------------------

# MODIFIED 2018-05-05 \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
#

FinalizeExportComplexObjectsToCSVviaJQ () {
    #
    # The FinalizeExportComplexObjectsToCSVviaJQ is the finaling actions for the script's repeated actions.
    #

    if [ ! -r "$APICLICSVfileheader" ] ; then
        # Uh, Oh, something went wrong, no header file
        echo | tee -a -i $APICLIlogfilepath
        echo '!!!! Error header file missing : '$APICLICSVfileheader | tee -a -i $APICLIlogfilepath
        echo 'Terminating!' | tee -a -i $APICLIlogfilepath
        echo | tee -a -i $APICLIlogfilepath
        return 254
        
    elif [ ! -r "$APICLICSVfiledata" ] ; then
        # Uh, Oh, something went wrong, no data file
        echo | tee -a -i $APICLIlogfilepath
        echo '!!!! Error data file missing : '$APICLICSVfiledata | tee -a -i $APICLIlogfilepath
        echo 'Terminating!' | tee -a -i $APICLIlogfilepath
        echo | tee -a -i $APICLIlogfilepath
        return 253
        
    elif [ ! -s "$APICLICSVfiledata" ] ; then
        # data file is empty, nothing was found
        echo | tee -a -i $APICLIlogfilepath
        echo '!! data file is empty : '$APICLICSVfiledata | tee -a -i $APICLIlogfilepath
        echo 'Skipping CSV creation!' | tee -a -i $APICLIlogfilepath
        echo | tee -a -i $APICLIlogfilepath
        return 0
        
    fi

    echo | tee -a -i $APICLIlogfilepath
    echo "Sort data and build CSV export file" | tee -a -i $APICLIlogfilepath
    echo | tee -a -i $APICLIlogfilepath
    
    cat $APICLICSVfileheader > $APICLICSVfileoriginal
    cat $APICLICSVfiledata >> $APICLICSVfileoriginal
    
    sort $APICLICSVsortparms $APICLICSVfiledata > $APICLICSVfilesort
    
    cat $APICLICSVfileheader > $APICLICSVfile
    cat $APICLICSVfilesort >> $APICLICSVfile
    
    echo | tee -a -i $APICLIlogfilepath
    echo "Done creating $APICLIcomplexobjectstype CSV File : $APICLICSVfile" | tee -a -i $APICLIlogfilepath
    echo | tee -a -i $APICLIlogfilepath
    
    head $APICLICSVfile | tee -a -i $APICLIlogfilepath
    echo | tee -a -i $APICLIlogfilepath
    echo | tee -a -i $APICLIlogfilepath
    
    
    echo | tee -a -i $APICLIlogfilepath
    return 0
    
}

# -------------------------------------------------------------------------------------------------

#
# /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\ MODIFIED 2018-05-05

# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------

#
# /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\  ADDED 2017-11-09


# MODIFIED 2017-11-09 \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
#

# -------------------------------------------------------------------------------------------------
# group members
# -------------------------------------------------------------------------------------------------

export APICLIobjecttype=group
export APICLIobjectstype=groups
export APICLIcomplexobjecttype=group-member
export APICLIcomplexobjectstype=group-members
export APICLIexportnameaddon=

# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------

# -------------------------------------------------------------------------------------------------
# SetupGetGroupMembers proceedure
# -------------------------------------------------------------------------------------------------

#
# SetupGetGroupMembers

SetupGetGroupMembers () {

    #
    # APICLICSVsortparms can change due to the nature of the object
    #
    export APICLICSVsortparms='-f -t , -k 1,2'
    
    export CSVFileHeader='"name","members.add"'
    
    SetupExportComplexObjectsToCSVviaJQ
    
    return 0
}
    
# -------------------------------------------------------------------------------------------------
# FinalizeGetGroupMembers proceedure
# -------------------------------------------------------------------------------------------------

#
# FinalizeGetGroupMembers

# MODIFIED 2018-05-05 \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
#

FinalizeGetGroupMembers () {

    FinalizeExportComplexObjectsToCSVviaJQ
    errorreturn=$?
    if [ $errorreturn != 0 ] ; then
        # Something went wrong, terminate
        return $errorreturn
    fi
    
    return 0
}
    

#
# /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\ MODIFIED 2018-05-05
# MODIFIED 2018-03-05 \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
#


# -------------------------------------------------------------------------------------------------
# PopulateArrayOfGroupObjects proceedure
# -------------------------------------------------------------------------------------------------

#
# PopulateArrayOfGroupObjects generates an array of group objects for further processing.

PopulateArrayOfGroupObjects () {
    
    # MODIFIED 2018-07-20 -
    
    # System Object selection operands
    # This one won't work because upgrades set all objects to creator = System"
    # export notsystemobjectselector='select(."meta-info"."creator" != "System")'
    #export notsystemobjectselector='select(."meta-info"."creator" | contains ("System") | not)'
    #
    # This should work if assumptions aren't wrong
    #export notsystemobjectselector='select(."domain"."name" != "Check Point Data")'
    
    #
    # This should work, but might need more tweeks if other data types use more values
    #export notsystemobjectselector='select(."domain"."name" | contains ("Check Point Data", "APPI Data", "IPS Data") | not)'
    #export notsystemobjectselector='select(any(."domain"."name"; in("Check Point Data", "APPI Data", "IPS Data")) | not)'
    #export notsystemobjectselector='select((."domain"."name" != "Check Point Data") and (."domain"."name" != "APPI Data") and (."domain"."name" != "IPS Data"))'
    
    #
    # Future alternative if more options to exclude are needed
    export systemobjectdomains='"Check Point Data", "APPI Data", "IPS Data"'
    export notsystemobjectselector='select(."domain"."name" as $a | ['$systemobjectdomains'] | index($a) | not)'
    
    echo "  $APICLIobjectstype - Populate up to next $APICLIObjectLimit $APICLIobjecttype objects starting with object $currentgroupoffset of $objectslefttoshow remaining!"

    # MGMT_CLI_GROUPS_STRING is a string with multiple lines. Each line contains a name of a group members.
    # in this example the output of mgmt_cli is not sent to a file, instead it is passed to jq directly using a pipe.
    
    #MGMT_CLI_GROUPS_STRING="`mgmt_cli show groups limit $APICLIObjectLimit offset $currentgroupoffset details-level "standard" -s $APICLIsessionfile -f json | $JQ ".objects[].name | @sh" -r`"
    
    if [ x"$NoSystemObjects" = x"true" ] ; then
        # Ignore System Objects
        #MGMT_CLI_GROUPS_STRING="`mgmt_cli show groups limit $APICLIObjectLimit offset $currentgroupoffset details-level "full" -s $APICLIsessionfile -f json | $JQ ".objects[] | '"$notsystemobjectselector"' | .name | @sh" -r`"
        MGMT_CLI_GROUPS_STRING="`mgmt_cli show groups limit $APICLIObjectLimit offset $currentgroupoffset details-level "full" -s $APICLIsessionfile -f json | $JQ '.objects[] | '"$notsystemobjectselector"' | .name | @sh' -r`"
    else   
        # Don't Ignore System Objects
        MGMT_CLI_GROUPS_STRING="`mgmt_cli show groups limit $APICLIObjectLimit offset $currentgroupoffset details-level "standard" -s $APICLIsessionfile -f json | $JQ ".objects[].name | @sh" -r`"
    fi
    
    # break the string into an array - each element of the array is a line in the original string
    # there are simpler ways, but this way allows the names to contain spaces. Gaia's bash version is 3.x so readarray is not available
    
    while read -r line; do
        ALLGROUPARR+=("$line")
        echo -n '.'
    done <<< "$MGMT_CLI_GROUPS_STRING"
    echo
    
    return 0
}

#
# /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\ MODIFIED 2018-03-05


# -------------------------------------------------------------------------------------------------
# GetArrayOfGroupObjects proceedure
# -------------------------------------------------------------------------------------------------

#
# GetArrayOfGroupObjects generates an array of group objects for further processing.

GetArrayOfGroupObjects () {
    
    #
    # APICLICSVsortparms can change due to the nature of the object
    #
    
    echo
    echo 'Generate array of groups'
    echo
    
    ALLGROUPARR=()

    export MgmtCLI_Base_OpParms="-f json -s $APICLIsessionfile"
    export MgmtCLI_IgnoreErr_OpParms="ignore-warnings true ignore-errors true --ignore-errors true"
    
    export MgmtCLI_Show_OpParms="details-level \"$APICLIdetaillvl\" $MgmtCLI_Base_OpParms"
    
    objectstotal=$(mgmt_cli show $APICLIobjectstype limit 1 offset 0 details-level "standard" $MgmtCLI_Base_OpParms | $JQ ".total")

    objectstoshow=$objectstotal

    echo "Processing $objectstoshow $APICLIobjecttype objects in $APICLIObjectLimit object chunks:"

    objectslefttoshow=$objectstoshow

    currentgroupoffset=0
    
    while [ $objectslefttoshow -ge 1 ] ; do
        # we have objects to process
        echo "  Now processing up to next $APICLIObjectLimit $APICLIobjecttype objects starting with object $currentgroupoffset of $objectslefttoshow remaining!"

        PopulateArrayOfGroupObjects
        errorreturn=$?
        if [ $errorreturn != 0 ] ; then
            # Something went wrong, terminate
            return $errorreturn
        fi

        objectslefttoshow=`expr $objectslefttoshow - $APICLIObjectLimit`
        currentgroupoffset=`expr $currentgroupoffset + $APICLIObjectLimit`
    done

    
    return 0
}


# -------------------------------------------------------------------------------------------------
# DumpArrayOfGroupObjects proceedure
# -------------------------------------------------------------------------------------------------

#
# DumpArrayOfGroupObjects outputs the array of group objects.

DumpArrayOfGroupObjects () {
    
    # print the elements in the array
    echo >> $APICLIlogfilepath
    echo Groups >> $APICLIlogfilepath
    echo >> $APICLIlogfilepath
    
    for i in "${ALLGROUPARR[@]}"
    do
        echo "$i, ${i//\'/}" >> $APICLIlogfilepath
    done
    
    return 0
}


# -------------------------------------------------------------------------------------------------
# CountMembersInGroupObjects proceedure
# -------------------------------------------------------------------------------------------------

#
# CountMembersInGroupObjects outputs the number of group members in a group in the array of group objects.

CountMembersInGroupObjects () {
        
        
    #
    # using bash variables in a jq expression
    #
    
    echo
    echo 'Use array of groups to count group members in each group'ls 
    echo
    echo >> $APICLIlogfilepath
    echo 'Use array of groups to count group members in each group' >> $APICLIlogfilepath
    echo >> $APICLIlogfilepath
    
    for i in "${ALLGROUPARR[@]}"
    do
    
        MEMBERS_COUNT=$(mgmt_cli show group name "${i//\'/}" -s $APICLIsessionfile -f json | $JQ ".members | length")
    
        echo Group "${i//\'/}"' number of members = '"$MEMBERS_COUNT"
        echo Group "${i//\'/}"' number of members = '"$MEMBERS_COUNT" >> $APICLIlogfilepath

    done
    
    return 0
}


# -------------------------------------------------------------------------------------------------

if [ $number_groups -le 0 ] ; then
    # No groups found
    echo
    echo 'No groups to generate members from!'
    echo
    echo >> $APICLIlogfilepath
    echo 'No groups to generate members from!' >> $APICLIlogfilepath
    echo >> $APICLIlogfilepath
else
    GetArrayOfGroupObjects
    DumpArrayOfGroupObjects
    CountMembersInGroupObjects
fi

# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------


# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------
# no more complex objects
# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------

# -------------------------------------------------------------------------------------------------
# no more objects
# -------------------------------------------------------------------------------------------------

echo
echo 'Dumps Completed!'
echo
echo >> $APICLIlogfilepath
echo 'Dumps Completed!' >> $APICLIlogfilepath
echo >> $APICLIlogfilepath


# =================================================================================================
# END:  Main operations - 
# =================================================================================================
# -------------------------------------------------------------------------------------------------
# =================================================================================================


# =================================================================================================
# =================================================================================================
# START:  Publish, Cleanup, and Dump output
# =================================================================================================


# -------------------------------------------------------------------------------------------------
# Publish Changes
# -------------------------------------------------------------------------------------------------

# MODIFIED 2018-05-02 -
 
HandleMgmtCLIPublish

# -------------------------------------------------------------------------------------------------
# Logout from mgmt_cli, also cleanup session file
# -------------------------------------------------------------------------------------------------

# MODIFIED 2018-05-02 -
 
HandleMgmtCLILogout

# -------------------------------------------------------------------------------------------------
# Clean-up and exit
# -------------------------------------------------------------------------------------------------

# MODIFIED 2018-05-04 \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
#

echo 'CLI Operations Completed' | tee -a -i $APICLIlogfilepath

if [ x"$CLIparm_CLEANUPWIP" = x"true" ] ; then
    # Remove Work-In-Progress folder and files

    if [ -r $APICLICSVpathexportwip ] ; then
        echo 'Remove CSV Work-In-Progress folder and files' | tee -a -i $APICLIlogfilepath
        echo '   CSV WIP Folder : '$APICLICSVpathexportwip | tee -a -i $APICLIlogfilepath
        rm -v -r $APICLICSVpathexportwip | tee -a -i $APICLIlogfilepath
    fi
    
    if [ -r $APICLIJSONpathexportwip ] ; then
        echo 'Remove JSON Work-In-Progress folder and files' | tee -a -i $APICLIlogfilepath
        echo '   JSON WIP Folder : '$APICLIJSONpathexportwip | tee -a -i $APICLIlogfilepath
        rm -v -r $APICLIJSONpathexportwip | tee -a -i $APICLIlogfilepath
    fi

fi


if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
    # Verbose mode ON

    echo | tee -a -i $APICLIlogfilepath
    #echo "Files in >$apiclipathroot<" | tee -a -i $APICLIlogfilepath
    #ls -alh $apiclipathroot | tee -a -i $APICLIlogfilepath
    #echo | tee -a -i $APICLIlogfilepath

    if [ "$APICLIlogpathbase" != "$APICLIpathbase" ] ; then
        echo "Files in >$APICLIlogpathbase<" | tee -a -i $APICLIlogfilepath
        ls -alhR $APICLIpathbase | tee -a -i $APICLIlogfilepath
        echo | tee -a -i $APICLIlogfilepath
    fi
    
    echo "Files in >$APICLIpathbase<" | tee -a -i $APICLIlogfilepath
    ls -alhR $APICLIpathbase | tee -a -i $APICLIlogfilepath
    echo | tee -a -i $APICLIlogfilepath
fi

echo | tee -a -i $APICLIlogfilepath
echo "Results in directory $APICLIpathbase" | tee -a -i $APICLIlogfilepath
echo "Log output in file $APICLIlogfilepath" | tee -a -i $APICLIlogfilepath
echo | tee -a -i $APICLIlogfilepath

#
# /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\ MODIFIED 2018-05-04


# =================================================================================================
# END:  Publish, Cleanup, and Dump output
# =================================================================================================
# =================================================================================================


