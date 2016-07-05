##
# Starts the server
##
mc_start() {
    servicejar=$SERVER_PATH/$SERVICE

    if [ ! -f "$servicejar" ]; then
        echo "Failed to start: Can't find the specified Minecraft jar at $servicejar. Please check your config!"
        exit 1
    fi

    pidfile=${SERVER_PATH}/${SCREEN}.pid
    check_permissions

    echo "Starting server..."

    as_user "cd $SERVER_PATH && screen -dmS $SCREEN $INVOCATION"
    as_user "screen -list | grep "\.$SCREEN" | cut -f1 -d'.' | head -n 1 | tr -d -c 0-9 > $pidfile"

    # Waiting for the server to start
    seconds=0
    until is_running; do
        sleep 1
        seconds=$seconds+1

        if [[ $seconds -eq 5 ]]; then
            echo "Still not running, waiting a while longer..."
        fi
        if [[ $seconds -eq 30 ]]; then
            echo "Still not running, waiting a few more seconds..."
        fi
        if [[ $seconds -ge 60 ]]; then
            echo "Still not running, assuming it failed to start, aborting."
            exit 1
        fi
    done
    echo "$SERVICE is running."
}