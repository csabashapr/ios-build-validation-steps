function validate_thatTheEmbeddedProfileHasTheSameAppGroupAsTheEntitlement()
{
    echo "\n"

    while [  true ]; do
        if [ "$#" -ne 1 ]; then
            echo "function $FUNCNAME : Did not receive 1 parameter"
            break #Print usage
        fi
        
        if [[ $1 == *".ipa" ]]; then
            echo "function $FUNCNAME : received *.ipa Path : $1"
        else
            echo "function $FUNCNAME : missing string : \".ipa\" from received *.ipa path. The received path is : $1"
            break #Print usage
        fi
        
        if [ ! -f "$1" ]; then
		  	# Control will enter here if $1 doesn't exist.
		  	echo "function $FUNCNAME : no file exists under the received path. The received path is : $1"
            break #Print usage
		fi
        
        #embedded plist : 
        #security cms -D -i join.me.app/embedded.mobileprovision > tmp.plist && /usr/libexec/PlistBuddy -c 'Print :Entitlements:com.apple.security.application-groups:0' tmp.plist
        #
        #entitlements : 
        #codesign -d --entitlements :- join.me.app > /tmp/entChecker.plist && /usr/libexec/PlistBuddy -c 'Print :com.apple.security.application-groups:0' /tmp/entChecker.plist
        
        #Step0.: Getting the app name based on the received ipa path : $1 : 
    	local APPNAME=`basename "$1"`
    	echo "function $FUNCNAME : Getting the app name based on the received ipa path : app name (not yet extracted from the received *.ipa Path) : $APPNAME"
    	local SUFFIX=".ipa"
        local APPNAME=`echo ${APPNAME%$SUFFIX}`
        echo "function $FUNCNAME : Getting the app name based on the received ipa path : app name (extracted from the received *.ipa Path) : $APPNAME"
        
        #Step1.: Extract ipa file : 
        echo "function $FUNCNAME : Extracting the received ipa : $1"
        TEMPORARYDIRECTORY=`mktemp -d -t $APPNAME`
        echo "Created TEMPORARYDIRECTORY with path : $TEMPORARYDIRECTORY"
        echo "function $FUNCNAME : contents of TEMPORARYDIRECTORY : "
        ls -la $TEMPORARYDIRECTORY
        #Make sure that we won't have temporary directories left behind even if our build is stopped
        trap "{ rm -rf $TEMPORARYDIRECTORY; echo \"function $FUNCNAME : Removing temporary directory : $TEMPORARYDIRECTORY\"; exit 255; }" SIGINT
        
        ditto -x -k $1 $TEMPORARYDIRECTORY
        echo "function $FUNCNAME : contents of TEMPORARYDIRECTORY : "
        ls -la "$TEMPORARYDIRECTORY"
        
        #Step2.: Get the identifiers from the extracted ipa file's *.app : 
        echo "function $FUNCNAME : Get the identifiers from the extracted ipa file's *.app : $1"
        APP_GROUP_IN_EMBEDDED_PLIST=$(security cms -D -i $TEMPORARYDIRECTORY/Payload/$APPNAME.app/embedded.mobileprovision > $TEMPORARYDIRECTORY/LMI_iOS_unique_tmp.plist && /usr/libexec/PlistBuddy -c 'Print :Entitlements:com.apple.security.application-groups:0' $TEMPORARYDIRECTORY/LMI_iOS_unique_tmp.plist)
        APP_GROUP_IN_ENTITLEMENT=$(codesign -d --entitlements :- $TEMPORARYDIRECTORY/Payload/$APPNAME.app > $TEMPORARYDIRECTORY/LMI_iOS_unique2_tmp.plist && /usr/libexec/PlistBuddy -c 'Print :com.apple.security.application-groups:0' $TEMPORARYDIRECTORY/LMI_iOS_unique2_tmp.plist)
        echo "function $FUNCNAME : APP_GROUP_IN_EMBEDDED_PLIST : $APP_GROUP_IN_EMBEDDED_PLIST"
        echo "function $FUNCNAME : APP_GROUP_IN_ENTITLEMENT : $APP_GROUP_IN_ENTITLEMENT"
        
        #Step3.: Removing temporary directory : 
        echo "function $FUNCNAME : Removing temporary directory : $TEMPORARYDIRECTORY"
        rm -rf $TEMPORARYDIRECTORY
        
        #Step4.: Check that they are the same : 
        if [ "$APP_GROUP_IN_EMBEDDED_PLIST" == "$APP_GROUP_IN_ENTITLEMENT" ]; then
        	echo "function $FUNCNAME : OK"
        else
        	echo "function $FUNCNAME : error: ___NOT___ OK"
        	exit 1
        fi

        echo "\n"
        return 0
    done

    #Print usage
    echo "function $FUNCNAME : Usage: $0 ipaFilePath"
    echo "\n"
    echo "function $FUNCNAME : parameters:"
    echo "function $FUNCNAME : \t ipaPath : Path to the generated ipa path."
    echo "\n"
    echo "function $FUNCNAME : Example : "
    echo "function $FUNCNAME : $FUNCNAME join.me.ipa"
    echo "\n"

    exit 1
}

function validate_thatApplicationIdentifiersAreTheCorrectOnes()
{
    echo "\n"

    while [  true ]; do
        if [ "$#" -ne 1 ]; then
            echo "function $FUNCNAME : Did not receive 1 parameter"
            break #Print usage
        fi

        if [[ $1 == *".ipa" ]]; then
            echo "function $FUNCNAME : received *.ipa Path : $1"
        else
            echo "function $FUNCNAME : missing string : \".ipa\" from received *.ipa path. The received path is : $1"
            break #Print usage
        fi

        if [ ! -f "$1" ]; then
            # Control will enter here if $1 doesn't exist.
            echo "function $FUNCNAME : no file exists under the received path. The received path is : $1"
            break #Print usage
        fi

        #embedded plist :
        #security cms -D -i join.me.app/embedded.mobileprovision > tmp.plist && /usr/libexec/PlistBuddy -c 'Print :Entitlements:com.apple.security.application-groups:0' tmp.plist
        #
        #entitlements :
        #codesign -d --entitlements :- join.me.app > /tmp/entChecker.plist && /usr/libexec/PlistBuddy -c 'Print :com.apple.security.application-groups:0' /tmp/entChecker.plist

        #Step0.: Getting the app name based on the received ipa path : $1 :
        local APPNAME=`basename "$1"`
        echo "function $FUNCNAME : Getting the app name based on the received ipa path : app name (not yet extracted from the received *.ipa Path) : $APPNAME"
        local SUFFIX=".ipa"
        local APPNAME=`echo ${APPNAME%$SUFFIX}`
        echo "function $FUNCNAME : Getting the app name based on the received ipa path : app name (extracted from the received *.ipa Path) : $APPNAME"

        #Step1.: Extract ipa file :
        echo "function $FUNCNAME : Extracting the received ipa : $1"
        TEMPORARYDIRECTORY=`mktemp -d -t $APPNAME`
        echo "Created TEMPORARYDIRECTORY with path : $TEMPORARYDIRECTORY"
        echo "function $FUNCNAME : contents of TEMPORARYDIRECTORY : "
        ls -la $TEMPORARYDIRECTORY
        #Make sure that we won't have temporary directories left behind even if our build is stopped
        trap "{ rm -rf $TEMPORARYDIRECTORY; echo \"function $FUNCNAME : Removing temporary directory : $TEMPORARYDIRECTORY\"; exit 255; }" SIGINT

        ditto -x -k $1 $TEMPORARYDIRECTORY
        echo "function $FUNCNAME : contents of TEMPORARYDIRECTORY : "
        ls -la "$TEMPORARYDIRECTORY"

        #Step2.: Get the identifiers from the extracted ipa file's *.app :
        echo "function $FUNCNAME : Get the identifiers from the extracted ipa file's *.app : $1"
        APP_MOBILEPROVISION_APPLICATION_IDENTIFIER=$(security cms -D -i $TEMPORARYDIRECTORY/Payload/$APPNAME.app/embedded.mobileprovision > $TEMPORARYDIRECTORY/LMI_iOS_unique_tmp.plist && /usr/libexec/PlistBuddy -c 'Print :Entitlements:application-identifier' $TEMPORARYDIRECTORY/LMI_iOS_unique_tmp.plist)
        APP_ENTITLEMENTS_APPLICATION_IDENTIFIER=$(codesign -d --entitlements :- $TEMPORARYDIRECTORY/Payload/$APPNAME.app > $TEMPORARYDIRECTORY/LMI_iOS_unique_tmp.plist && /usr/libexec/PlistBuddy -c 'Print :application-identifier' $TEMPORARYDIRECTORY/LMI_iOS_unique_tmp.plist)

        echo -e "APP_MOBILEPROVISION_APPLICATION_IDENTIFIER:\t$APP_MOBILEPROVISION_APPLICATION_IDENTIFIER"
        echo -e "APP_ENTITLEMENTS_APPLICATION_IDENTIFIER:\t$APP_ENTITLEMENTS_APPLICATION_IDENTIFIER"
        echo

        WATCHKIT_APP_MOBILEPROVISION_APPLICATION_IDENTIFIER=$(security cms -D -i $TEMPORARYDIRECTORY/Payload/$APPNAME.app/PlugIns/$APPNAME\ WatchKit\ Extension.appex/$APPNAME\ WatchKit\ App.app/embedded.mobileprovision > $TEMPORARYDIRECTORY/LMI_iOS_unique_tmp.plist && /usr/libexec/PlistBuddy -c 'Print :Entitlements:application-identifier' $TEMPORARYDIRECTORY/LMI_iOS_unique_tmp.plist)
        WATCHKIT_APP_ENTITLEMENTS_APPLICATION_IDENTIFIER=$(codesign -d --entitlements :- $TEMPORARYDIRECTORY/Payload/$APPNAME.app/PlugIns/$APPNAME\ WatchKit\ Extension.appex/$APPNAME\ WatchKit\ App.app > $TEMPORARYDIRECTORY/LMI_iOS_unique_tmp.plist && /usr/libexec/PlistBuddy -c 'Print :application-identifier' $TEMPORARYDIRECTORY/LMI_iOS_unique_tmp.plist)

        echo -e "WATCHKIT_APP_MOBILEPROVISION_APPLICATION_IDENTIFIER:\t$WATCHKIT_APP_MOBILEPROVISION_APPLICATION_IDENTIFIER"
        echo -e "WATCHKIT_APP_ENTITLEMENTS_APPLICATION_IDENTIFIER:\t$WATCHKIT_APP_ENTITLEMENTS_APPLICATION_IDENTIFIER"
        echo

        WATCHKIT_EXTENSION_APP_MOBILEPROVISION_APPLICATION_IDENTIFIER=$(security cms -D -i $TEMPORARYDIRECTORY/Payload/$APPNAME.app/PlugIns/$APPNAME\ WatchKit\ Extension.appex/embedded.mobileprovision > $TEMPORARYDIRECTORY/LMI_iOS_unique_tmp.plist && /usr/libexec/PlistBuddy -c 'Print :Entitlements:application-identifier' $TEMPORARYDIRECTORY/LMI_iOS_unique_tmp.plist)
        WATCHKIT_EXTENSION_APP_ENTITLEMENTS_APPLICATION_IDENTIFIER=$(codesign -d --entitlements :- $TEMPORARYDIRECTORY/Payload/$APPNAME.app/PlugIns/$APPNAME\ WatchKit\ Extension.appex > $TEMPORARYDIRECTORY/LMI_iOS_unique_tmp.plist && /usr/libexec/PlistBuddy -c 'Print :application-identifier' $TEMPORARYDIRECTORY/LMI_iOS_unique_tmp.plist)

        echo -e "WATCHKIT_EXTENSION_APP_MOBILEPROVISION_APPLICATION_IDENTIFIER:\t$WATCHKIT_EXTENSION_APP_MOBILEPROVISION_APPLICATION_IDENTIFIER"
        echo -e "WATCHKIT_EXTENSION_APP_ENTITLEMENTS_APPLICATION_IDENTIFIER:\t$WATCHKIT_EXTENSION_APP_ENTITLEMENTS_APPLICATION_IDENTIFIER"
        echo "\n"

        #Step3.: Removing temporary directory :
        echo "function $FUNCNAME : Removing temporary directory : $TEMPORARYDIRECTORY"
        rm -rf $TEMPORARYDIRECTORY

        #Step4.: Check that they are the same :
        if [ "$APP_MOBILEPROVISION_APPLICATION_IDENTIFIER" == "$APP_ENTITLEMENTS_APPLICATION_IDENTIFIER" ]; then
            echo "function $FUNCNAME : OK (APP_MOBILEPROVISION_APPLICATION_IDENTIFIER == APP_ENTITLEMENTS_APPLICATION_IDENTIFIER)"
        else
            echo "function $FUNCNAME : error: ___NOT___ OK (APP_MOBILEPROVISION_APPLICATION_IDENTIFIER != APP_ENTITLEMENTS_APPLICATION_IDENTIFIER)"
            exit 1
        fi

        if [ "$WATCHKIT_APP_MOBILEPROVISION_APPLICATION_IDENTIFIER" == "$WATCHKIT_APP_ENTITLEMENTS_APPLICATION_IDENTIFIER" ]; then
            echo "function $FUNCNAME : OK (WATCHKIT_APP_MOBILEPROVISION_APPLICATION_IDENTIFIER == WATCHKIT_APP_ENTITLEMENTS_APPLICATION_IDENTIFIER)"
        else
            echo "function $FUNCNAME : error: ___NOT___ OK (WATCHKIT_APP_MOBILEPROVISION_APPLICATION_IDENTIFIER != WATCHKIT_APP_ENTITLEMENTS_APPLICATION_IDENTIFIER)"
            exit 1
        fi

        if [ "$WATCHKIT_EXTENSION_APP_MOBILEPROVISION_APPLICATION_IDENTIFIER" == "$WATCHKIT_EXTENSION_APP_ENTITLEMENTS_APPLICATION_IDENTIFIER" ]; then
            echo "function $FUNCNAME : OK (WATCHKIT_EXTENSION_APP_MOBILEPROVISION_APPLICATION_IDENTIFIER == WATCHKIT_EXTENSION_APP_ENTITLEMENTS_APPLICATION_IDENTIFIER)"
        else
            echo "function $FUNCNAME : error: ___NOT___ OK (WATCHKIT_EXTENSION_APP_MOBILEPROVISION_APPLICATION_IDENTIFIER != WATCHKIT_EXTENSION_APP_ENTITLEMENTS_APPLICATION_IDENTIFIER)"
            exit 1
        fi
        echo "\n"
        return 0
    done

    #Print usage
    echo "function $FUNCNAME : Usage: $0 ipaFilePath"
    echo "\n"
    echo "function $FUNCNAME : parameters:"
    echo "function $FUNCNAME : \t ipaPath : Path to the generated ipa path."
    echo "\n"
    echo "function $FUNCNAME : Example : "
    echo "function $FUNCNAME : $FUNCNAME join.me.ipa"
    echo "\n"

    exit 1
}

