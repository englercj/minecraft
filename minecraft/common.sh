##
# Runs all commands as the non-root user
##
as_user() {
    if [ "$ME" == "$USERNAME" ]; then
        bash -c "$1"
    else
        su $USERNAME -s /bin/bash -c "$1"
    fi
}

##
# Check if the server is running or not, and get
# the Java Process ID if it is.
##
is_running() {
    # Checks for the minecraft servers screen session
    # returns true if it exists.
    pidfile=${SERVER_PATH}/${SCREEN}.pid

    if [ -f "$pidfile" ]; then
        SCREENPID=$(head -1 $pidfile)

        if ps ax | grep -v grep | grep ${SCREENPID} | grep "${SCREEN}" > /dev/null
        then
            return 0
        else
            echo "Rogue pidfile found, removing."
            as_user "rm $pidfile"
            return 1
        fi
    else
        if ps ax | grep -v grep | grep "${SCREEN} ${INVOCATION}" > /dev/null
        then
            echo "No pidfile found, but server's running."
            echo "Re-creating the pidfile."

            SCREENPID=$(ps ax | grep -v grep | grep "${SCREEN} ${INVOCATION}" | cut -f1 -d' ')
            check_permissions
            as_user "echo $SCREENPID > $pidfile"

            return 0
        else
            return 1
        fi
    fi
}

##
# Returns an file path with added date between the filename and file ending.
# $1 filepath (not including file ending)
# $2 file ending to check for uniqueness
# $3 file ending to return
##
datepath() {
    if [ -e $1`date +%F`$2 ]; then
        echo $1`date +%FT%T`$3
    else
        echo $1`date +%F`$3
    fi
}

##
# Ensures permissions of the pidfile are correct
##
check_permissions() {
    as_user "touch $pidfile"

    if ! as_user "test -w '$pidfile'" ; then
        echo "Check Permissions. Cannot write to $pidfile. Correct the permissions and then excute: $0 status"
    fi
}

##
# Gets the location of the running script
##
get_script_location() {
    echo $(dirname "$(readlink -e "$0")")
}

##
# Gets the list of worlds
##
get_worlds() {
    SAVEIFS=$IFS
    IFS=$(echo -en "\n\b")

    a=1
    for NAME in $(ls $WORLDS_PATH); do
        if [ -d $WORLDS_PATH/$NAME ]; then
            WORLDNAME[$a]=$NAME

            if [ -e $WORLDS_PATH/$NAME/ramdisk ]; then
                WORLDRAM[$a]=true
            else
                WORLDRAM[$a]=false
            fi

            a=$a+1
        fi
    done

    IFS=$SAVEIFS
}

##
# Checks the links for the worlds and ensures they are properly in place.
##
check_links() {
    get_worlds

    for INDEX in ${!WORLDNAME[@]}; do
        if [[ -L $SERVER_PATH/${WORLDNAME[$INDEX]} || ! -a $SERVER_PATH/${WORLDNAME[$INDEX]} ]]; then
            link=`ls -l $SERVER_PATH/${WORLDNAME[$INDEX]} | awk '{print $11}'`

            if ${WORLDRAM[$INDEX]}; then
                if [ "$link" != "$RAMDISK_PATH/${WORLDNAME[$INDEX]}" ]; then
                    as_user "rm -f $SERVER_PATH/${WORLDNAME[$INDEX]}"
                    as_user "ln -s $RAMDISK_PATH/${WORLDNAME[$INDEX]} $SERVER_PATH/${WORLDNAME[$INDEX]}"
                    echo "Created link for ${WORLDNAME[$INDEX]}"
                fi
            else
                if [ "$link" != "${WORLDS_PATH}/${WORLDNAME[$INDEX]}" ]; then
                    as_user "rm -f $SERVER_PATH/${WORLDNAME[$INDEX]}"
                    as_user "ln -s ${WORLDS_PATH}/${WORLDNAME[$INDEX]} $SERVER_PATH/${WORLDNAME[$INDEX]}"
                    echo "Created link for ${WORLDNAME[$INDEX]}"
                fi
            fi
        else
            echo "Could not process the world named '${WORLDNAME[$INDEX]}'. Please move all worlds to ${WORLDS_PATH}."

            return 1
        fi
    done
}

##
# Moves the world from hard disk to ramdisk
##
to_ram() {
    get_worlds

    for INDEX in ${!WORLDNAME[@]}; do
        if ${WORLDRAM[$INDEX]}; then
            if [ -L $SERVER_PATH/${WORLDNAME[$INDEX]} ]; then
                as_user "mkdir -p $RAMDISK_PATH"
                as_user "rsync -rt --exclude 'ramdisk' ${WORLDS_PATH}/${WORLDNAME[$INDEX]}/ $RAMDISK_PATH/${WORLDNAME[$INDEX]}"
                echo "${WORLDNAME[$INDEX]} copied to ram"
            fi
        fi
    done
}

##
# Moves the world from ramdisk to hard disk
##
to_disk() {
    get_worlds

    for INDEX in ${!WORLDNAME[@]}; do
        if ${WORLDRAM[$INDEX]}; then
            as_user "rsync -rt --exclude 'ramdisk' $SERVER_PATH/${WORLDNAME[$INDEX]}/ ${WORLDS_PATH}/${WORLDNAME[$INDEX]}"
            echo "${WORLDNAME[$INDEX]} copied to disk"
        fi
    done
}

##
# Sets whether to use ramdisk for a world
##
change_ramdisk_state() {
    if [ ! -e $WORLDS_PATH/$1 ]; then
        echo "World \"$1\" not found at $WORLDS_PATH/$1."
        exit 1
    fi

    if [ -e $WORLDS_PATH/$1/ramdisk ]; then
        rm $WORLDS_PATH/$1/ramdisk
        echo "Removed ramdisk flag from \"$1\""
    else
        touch $WORLDS_PATH/$1/ramdisk
        echo "Added ramdisk flag to \"$1\""
    fi

    echo "Changes will only take effect after server is restarted."
}

##
# Kill the server running (messily) in an emergency
##
mc_force_exit() {
    echo ""
    echo "SIGINIT CALLED - FORCE EXITING!"
    pidfile=${SERVER_PATH}/${SCREEN}.pid

    rm $pidfile

    echo "KILLING SERVER PROCESSES!!!"
        # Display which processes are being killed
        ps aux | grep -e 'java -Xmx' | grep -v grep | awk '{print $2}' | xargs -i echo "Killing PID: " {}
        ps aux | grep -e 'SCREEN -dmS minecraft java' | grep -v grep | awk '{print $2}' | xargs -i echo "Killing PID: " {}
        ps aux | grep -e '/etc/init.d/minecraft' | grep -v grep | awk '{print $2}' | xargs -i echo "Killing PID: " {}

        # Kill the processes
        ps aux | grep -e 'java -Xmx' | grep -v grep | awk '{print $2}' | xargs -i kill {}
        ps aux | grep -e 'SCREEN -dmS minecraft java' | grep -v grep | awk '{print $2}' | xargs -i kill {}
        ps aux | grep -e '/etc/init.d/minecraft' | grep -v grep | awk '{print $2}' | xargs -i kill {}
    exit 1
}
