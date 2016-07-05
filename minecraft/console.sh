##
# Enters the server console
##
mc_console() {
    if is_running; then
        as_user "screen -S $SCRNAME -dr"
    else
        echo "$SERVERNAME was not running! Unable to open console."
        exit 1
    fi
}

##
# Executes a command on the server
##
mc_command() {
    if is_running; then
        as_user "screen -p 0 -S $SCREEN -X eval 'stuff \"$(eval echo $FORMAT)\"\015'"
    else
        echo "$SERVICE was not running. Not able to run command."
    fi
}

##
# Disables saving temporarily.
##
mc_saveoff() {
    if is_running; then
        echo "$SERVICE is running... suspending saves"
        mc_command save-off
        mc_command save-all
        sync
        sleep 10
    else
        echo "$SERVICE was not running. Not suspending saves."
    fi
}

##
# Enables saving.
##
mc_saveon() {
    if is_running; then
        echo "$SERVICE is running... re-enabling saves"
        mc_command save-on
    else
        echo "$SERVICE was not running. Not resuming saves."
    fi
}

##
# Enables saving.
##
mc_say() {
    if is_running; then
        echo "Said: $1"
        mc_command "say $1"
    else
        echo "$SERVICE was not running. Not able to say anything."
    fi
}

##
# Reloads the server
##
mc_reload() {
    echo "$SERVICE is running... reloading."
    mc_command reload
}

##
# Prints the user whitelist
##
mc_whitelist(){
    mc_command "whitelist list"
    sleep 1
    whitelist=$(tac $LOG_PATH | grep -m 1 "whitelisted players:")

    echo
    echo "Currently there are the following players on your whitelist:"
    echo
    echo ${whitelist:49} | sed 's/, /\n/g'
}
