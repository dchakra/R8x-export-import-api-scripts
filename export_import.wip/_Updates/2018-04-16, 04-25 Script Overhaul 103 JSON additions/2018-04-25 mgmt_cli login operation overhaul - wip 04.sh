# MODIFIED 2018-04-25-4 \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
#

# =================================================================================================
# =================================================================================================
# START:  Setup Login Parameters and Login to Mgmt_CLI
# =================================================================================================


# ================================================================================================
# NOTE:  APICLIadmin value must be set to operate this script, removing this varaiable will lead
#        to logon failure with mgmt_cli logon.  Root User (-r) parameter is handled differently,
#        so DO NOT REMOVE OR CLEAR this variable.
# ================================================================================================
if [ x"$CLIparm_user" != x"" ] ; then
    export APICLIadmin=$CLIparm_user
else
    #export APICLIadmin=admin
    export APICLIadmin=administrator
fi

if [ x"$CLIparm_sessionidfile" != x"" ] ; then
    export APICLIsessionfile=$CLIparm_sessionidfile
else
    export APICLIsessionfile=id.txt
fi


#
# Testing - Dump aquired values
#
echo 'APICLIadmin       :  '$APICLIadmin
echo 'APICLIsessionfile :  '$APICLIsessionfile
echo

echo
echo 'mgmt_cli Login!'
echo
echo 'Login to mgmt_cli as '$APICLIadmin' and save to session file :  '$APICLIsessionfile
echo

export loginstring=
export loginparmstring=
export mgmttarget=
export domaintarget=

if [ x"$CLIparm_rootuser" = x"true" ] ; then
    # Handle if ROOT User -r true parameter

	export loginparmstring=' -r true'

    if [ x"$CLIparm_domain" != x"" ] ; then
    # Handle domain parameter for login string
        export loginparmstring=$loginparmstring" domain \"$CLIparm_domain\""

        if [ x"$CLIparm_websslport" != x"" ] ; then
            # Handle web ssl port parameter for login string
            export loginparmstring=$loginparmstring" --port $CLIparm_websslport"

            # Handle management server parameter for mgmt_cli parms
            if [ x"$CLIparm_mgmt" != x"" ] ; then
                export mgmttarget="-m \"$CLIparm_mgmt\""
 
                #
                # Testing - Dump login string bullt from parameters
                #
                if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
                    echo 'Execute login with loginparmstring '\"$loginparmstring\"' As Root with Domain and Management and Port'
                    echo 'Execute operations with mgmttarget '\"$mgmttarget\"
                    echo
                fi
                
                mgmt_cli login -r true domain "$CLIparm_domain" -m "$CLIparm_mgmt" --port $CLIparm_websslport > $APICLIsessionfile
                EXITCODE=$?

            else

                #
                # Testing - Dump login string bullt from parameters
                #
                if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
                    echo 'Execute login with loginparmstring '\"$loginparmstring\"' As Root with Domain and Port'
                    echo
                fi
                
                mgmt_cli login -r true domain "$CLIparm_domain" --port $CLIparm_websslport > $APICLIsessionfile
                EXITCODE=$?

            fi
        else
            # Handle management server parameter for mgmt_cli parms
            if [ x"$CLIparm_mgmt" != x"" ] ; then
                export mgmttarget="-m \"$CLIparm_mgmt\""

                #
                # Testing - Dump login string bullt from parameters
                #
                if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
                    echo 'Execute login with loginparmstring '\"$loginparmstring\"' As Root with Domain and Management'
                    echo 'Execute operations with mgmttarget '\"$mgmttarget\"
                    echo
                fi
                
                mgmt_cli login -r true domain "$CLIparm_domain" -m "$CLIparm_mgmt" > $APICLIsessionfile
                EXITCODE=$?

            else

                #
                # Testing - Dump login string bullt from parameters
                #
                if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
                    echo 'Execute login with loginparmstring '\"$loginparmstring\"' As Root with Domain'
                    echo
                fi
                
                mgmt_cli login -r true domain "$CLIparm_domain" > $APICLIsessionfile
                EXITCODE=$?

            fi
        fi
    else
        if [ x"$CLIparm_websslport" != x"" ] ; then
            # Handle web ssl port parameter for login string
            export loginparmstring=$loginparmstring" --port $CLIparm_websslport"

            # Handle management server parameter for mgmt_cli parms
            if [ x"$CLIparm_mgmt" != x"" ] ; then
                export mgmttarget="-m \"$CLIparm_mgmt\""

                #
                # Testing - Dump login string bullt from parameters
                #
                if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
                    echo 'Execute login with loginparmstring '\"$loginparmstring\"' As Root with Management and Port'
                    echo 'Execute operations with mgmttarget '\"$mgmttarget\"
                    echo
                fi
                
                mgmt_cli login -r true --port $CLIparm_websslport -m "$CLIparm_mgmt" > $APICLIsessionfile
                EXITCODE=$?

            else

                #
                # Testing - Dump login string bullt from parameters
                #
                if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
                    echo 'Execute login with loginparmstring '\"$loginparmstring\"' As Root with Port'
                    echo
                fi
                
                mgmt_cli login -r true --port $CLIparm_websslport > $APICLIsessionfile
                EXITCODE=$?

            fi
        else
            # Handle management server parameter for mgmt_cli parms
            if [ x"$CLIparm_mgmt" != x"" ] ; then
                export mgmttarget='-m \"$CLIparm_mgmt\"'

                #
                # Testing - Dump login string bullt from parameters
                #
                if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
                    echo 'Execute login with loginparmstring '\"$loginparmstring\"' As Root with Management'
                    echo 'Execute operations with mgmttarget '\"$mgmttarget\"
                    echo
                fi
                
                mgmt_cli login -r true -m "$CLIparm_mgmt" > $APICLIsessionfile
                EXITCODE=$?

            else

                #
                # Testing - Dump login string bullt from parameters
                #
                if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
                    echo 'Execute login with loginparmstring '\"$loginparmstring\"' As Root'
                    echo
                fi
                
                mgmt_cli login -r true > $APICLIsessionfile
                EXITCODE=$?

            fi
        fi
    fi
else
    # Handle User

    export loginparmstring=

    if [ x"$APICLIadmin" != x"" ] ; then
        export loginparmstring=$loginparmstring" user $APICLIadmin"
    else
        echo
        echo "mgmt_cli parameter error!!!!"
        echo "Admin User variable not set!!!"
        echo
        echo "Terminating script..."
        echo
        exit 255
    fi

    if [ x"$CLIparm_password" != x"" ] ; then
        # Handle password parameter
        export loginparmstring=$loginparmstring" password \"$CLIparm_password\""

        if [ x"$CLIparm_domain" != x"" ] ; then
            # Handle domain parameter for login string
            export loginparmstring=$loginparmstring" domain \"$CLIparm_domain\""
      
            if [ x"$CLIparm_websslport" != x"" ] ; then
                # Handle web ssl port parameter for login string
                export loginparmstring=$loginparmstring" --port $CLIparm_websslport"
      
                # Handle management server parameter for mgmt_cli parms
                if [ x"$CLIparm_mgmt" != x"" ] ; then
                    export mgmttarget="-m \"$CLIparm_mgmt\""
      
                    #
                    # Testing - Dump login string bullt from parameters
                    #
                    if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
                        echo 'Execute login with loginparmstring '\"$loginparmstring\"' As User with Password and Domain and Management and Port'
                        echo 'Execute operations with mgmttarget '\"$mgmttarget\"
                        echo
                    fi
                    
                    mgmt_cli login user $APICLIadmin password "$CLIparm_password" domain "$CLIparm_domain" -m "$CLIparm_mgmt" --port $CLIparm_websslport > $APICLIsessionfile
                    EXITCODE=$?
      
                else
      
                    #
                    # Testing - Dump login string bullt from parameters
                    #
                    if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
                        echo 'Execute login with loginparmstring '\"$loginparmstring\"' As User with Password and Domain and Port'
                        echo
                    fi
                    
                    mgmt_cli login user $APICLIadmin password "$CLIparm_password" domain "$CLIparm_domain" --port $CLIparm_websslport > $APICLIsessionfile
                    EXITCODE=$?
      
                fi
            else
                # Handle management server parameter for mgmt_cli parms
                if [ x"$CLIparm_mgmt" != x"" ] ; then
                    export mgmttarget="-m \"$CLIparm_mgmt\""
      
                    #
                    # Testing - Dump login string bullt from parameters
                    #
                    if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
                        echo 'Execute login with loginparmstring '\"$loginparmstring\"' As User with Password and Domain and Management'
                        echo 'Execute operations with mgmttarget '\"$mgmttarget\"
                        echo
                    fi
                    
                    mgmt_cli login user $APICLIadmin password "$CLIparm_password" domain "$CLIparm_domain" -m "$CLIparm_mgmt" > $APICLIsessionfile
                    EXITCODE=$?
      
                else
      
                    #
                    # Testing - Dump login string bullt from parameters
                    #
                    if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
                        echo 'Execute login with loginparmstring '\"$loginparmstring\"' As User with Password and Domain'
                        echo
                    fi
                    
                    mgmt_cli login user $APICLIadmin password "$CLIparm_password" domain "$CLIparm_domain" > $APICLIsessionfile
                    EXITCODE=$?
      
                fi
            fi
        else
            if [ x"$CLIparm_websslport" != x"" ] ; then
                # Handle web ssl port parameter for login string
                export loginparmstring=$loginparmstring" --port $CLIparm_websslport"
      
                # Handle management server parameter for mgmt_cli parms
                if [ x"$CLIparm_mgmt" != x"" ] ; then
                    export mgmttarget="-m \"$CLIparm_mgmt\""
      
                    #
                    # Testing - Dump login string bullt from parameters
                    #
                    if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
                        echo 'Execute login with loginparmstring '\"$loginparmstring\"' As User with Password and Management and Port'
                        echo 'Execute operations with mgmttarget '\"$mgmttarget\"
                        echo
                    fi
                    
                    mgmt_cli login user $APICLIadmin password "$CLIparm_password" --port $CLIparm_websslport -m "$CLIparm_mgmt" > $APICLIsessionfile
                    EXITCODE=$?
      
                else
      
                    #
                    # Testing - Dump login string bullt from parameters
                    #
                    if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
                        echo 'Execute login with loginparmstring '\"$loginparmstring\"' As User with Password and Port'
                        echo
                    fi
                    
                    mgmt_cli login user $APICLIadmin password "$CLIparm_password" --port $CLIparm_websslport > $APICLIsessionfile
                    EXITCODE=$?
      
                fi
            else
                # Handle management server parameter for mgmt_cli parms
                if [ x"$CLIparm_mgmt" != x"" ] ; then
                    export mgmttarget='-m \"$CLIparm_mgmt\"'
      
                    #
                    # Testing - Dump login string bullt from parameters
                    #
                    if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
                        echo 'Execute login with loginparmstring '\"$loginparmstring\"' As User with Password and Management'
                        echo 'Execute operations with mgmttarget '\"$mgmttarget\"
                        echo
                    fi
                    
                    mgmt_cli login user $APICLIadmin password "$CLIparm_password" -m "$CLIparm_mgmt" > $APICLIsessionfile
                    EXITCODE=$?
      
                else
      
                    #
                    # Testing - Dump login string bullt from parameters
                    #
                    if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
                        echo 'Execute login with loginparmstring '\"$loginparmstring\"' As User with Password'
                        echo
                    fi
                    
                    mgmt_cli login user $APICLIadmin password "$CLIparm_password" > $APICLIsessionfile
                    EXITCODE=$?
      
                fi
            fi
        fi
    else
        # Handle NO password parameter

        if [ x"$CLIparm_domain" != x"" ] ; then
            # Handle domain parameter for login string
            export loginparmstring=$loginparmstring" domain \"$CLIparm_domain\""
      
            if [ x"$CLIparm_websslport" != x"" ] ; then
                # Handle web ssl port parameter for login string
                export loginparmstring=$loginparmstring" --port $CLIparm_websslport"
      
                # Handle management server parameter for mgmt_cli parms
                if [ x"$CLIparm_mgmt" != x"" ] ; then
                    export mgmttarget="-m \"$CLIparm_mgmt\""
      
                    #
                    # Testing - Dump login string bullt from parameters
                    #
                    if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
                        echo 'Execute login with loginparmstring '\"$loginparmstring\"' As User with Domain and Management and Port'
                        echo 'Execute operations with mgmttarget '\"$mgmttarget\"
                        echo
                    fi
                    
                    mgmt_cli login user $APICLIadmin domain "$CLIparm_domain" -m "$CLIparm_mgmt" --port $CLIparm_websslport > $APICLIsessionfile
                    EXITCODE=$?
      
                else
      
                    #
                    # Testing - Dump login string bullt from parameters
                    #
                    if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
                        echo 'Execute login with loginparmstring '\"$loginparmstring\"' As User with Domain and Port'
                        echo
                    fi
                    
                    mgmt_cli login user $APICLIadmin domain "$CLIparm_domain" --port $CLIparm_websslport > $APICLIsessionfile
                    EXITCODE=$?
      
                fi
            else
                # Handle management server parameter for mgmt_cli parms
                if [ x"$CLIparm_mgmt" != x"" ] ; then
                    export mgmttarget="-m \"$CLIparm_mgmt\""
      
                    #
                    # Testing - Dump login string bullt from parameters
                    #
                    if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
                        echo 'Execute login with loginparmstring '\"$loginparmstring\"' As User with Domain and Management'
                        echo 'Execute operations with mgmttarget '\"$mgmttarget\"
                        echo
                    fi
                    
                    mgmt_cli login user $APICLIadmin domain "$CLIparm_domain" -m "$CLIparm_mgmt" > $APICLIsessionfile
                    EXITCODE=$?
      
                else
      
                    #
                    # Testing - Dump login string bullt from parameters
                    #
                    if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
                        echo 'Execute login with loginparmstring '\"$loginparmstring\"' As User with Domain'
                        echo
                    fi
                    
                    mgmt_cli login user $APICLIadmin domain "$CLIparm_domain" > $APICLIsessionfile
                    EXITCODE=$?
      
                fi
            fi
        else
            if [ x"$CLIparm_websslport" != x"" ] ; then
                # Handle web ssl port parameter for login string
                export loginparmstring=$loginparmstring" --port $CLIparm_websslport"
      
                # Handle management server parameter for mgmt_cli parms
                if [ x"$CLIparm_mgmt" != x"" ] ; then
                    export mgmttarget="-m \"$CLIparm_mgmt\""
      
                    #
                    # Testing - Dump login string bullt from parameters
                    #
                    if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
                        echo 'Execute login with loginparmstring '\"$loginparmstring\"' As User with Management and Port'
                        echo 'Execute operations with mgmttarget '\"$mgmttarget\"
                        echo
                    fi
                    
                    mgmt_cli login user $APICLIadmin --port $CLIparm_websslport -m "$CLIparm_mgmt" > $APICLIsessionfile
                    EXITCODE=$?
      
                else
      
                    #
                    # Testing - Dump login string bullt from parameters
                    #
                    if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
                        echo 'Execute login with loginparmstring '\"$loginparmstring\"' As User with Port'
                        echo
                    fi
                    
                    mgmt_cli login user $APICLIadmin --port $CLIparm_websslport > $APICLIsessionfile
                    EXITCODE=$?
      
                fi
            else
                # Handle management server parameter for mgmt_cli parms
                if [ x"$CLIparm_mgmt" != x"" ] ; then
                    export mgmttarget='-m \"$CLIparm_mgmt\"'
      
                    #
                    # Testing - Dump login string bullt from parameters
                    #
                    if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
                        echo 'Execute login with loginparmstring '\"$loginparmstring\"' As User with Management'
                        echo 'Execute operations with mgmttarget '\"$mgmttarget\"
                        echo
                    fi
                    
                    mgmt_cli login user $APICLIadmin -m "$CLIparm_mgmt" > $APICLIsessionfile
                    EXITCODE=$?
      
                else
      
                    #
                    # Testing - Dump login string bullt from parameters
                    #
                    if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
                        echo 'Execute login with loginparmstring '\"$loginparmstring\"' As User'
                        echo
                    fi
                    
                    mgmt_cli login user $APICLIadmin > $APICLIsessionfile
                    EXITCODE=$?
      
                fi
            fi
        fi
    fi
fi

if [ "$EXITCODE" != "0" ] ; then
    
    echo
    echo "mgmt_cli login error!"
    echo
    cat $APICLIsessionfile
    echo
    echo "Terminating script..."
    echo
    exit 255

else
    
    echo "mgmt_cli login success!"
    echo
    cat $APICLIsessionfile
    echo
    
fi


# =================================================================================================
# END:  Setup Login Parameters and Login to Mgmt_CLI
# =================================================================================================
# =================================================================================================

#
# /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\ MODIFIED 2018-04-25-4
