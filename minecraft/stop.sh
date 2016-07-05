##
# Stops the server
##
mc_stop() {
    pidfile=${MCPATH}/${SCREEN}.pid

    # Stops the server
    echo "Saving worlds..."
    mc_command save-all
    sleep 10

    echo "Stopping server..."
    mc_command stop
    sleep 0.5

    # Waiting for the server to shut down
    seconds=0
    while is_running; do
        sleep 1
        seconds=$seconds+1

        if [[ $seconds -eq 5 ]]; then
            echo "Still not shut down, waiting a while longer..."
        fi
        if [[ $seconds -eq 30 ]]; then
            echo "Still not shut down, waiting a few more seconds..."
        fi
        if [[ $seconds -ge 60 ]]; then
            logger -t minecraft-init "Failed to shut down server, aborting."
            echo "Failed to shut down, aborting."
            exit 1
        fi
    done

    as_user "rm $pidfile"
    echo "$SERVICE is now shut down."
}