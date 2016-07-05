##
# Prints info about the instance
##
mc_info() {
    if is_running; then
        RSS="$(ps --pid $SCREENPID --format rss | grep -v RSS)"
        echo " - Java Path          : $(readlink -f $(which java))"
        echo " - Start Command      : $INVOCATION"
        echo " - Server Path        : $SERVER_PATH"
        echo " - Process ID         : $SCREENPID"
        echo " - Screen Session     : $SCREEN"
        echo " - Memory Usage       : $((RSS/1024)) Mb ($RSS kb)"

        # Check for HugePages support in kernel, display statistics if HugePages are available, otherwise skip
        if [ -n "$(grep HugePages_Total /proc/meminfo | awk '{print $2}')" -a "$(grep HugePages_Total /proc/meminfo | awk '{print $2}')" ]; then
            HP_SIZE="$(grep Hugepagesize /proc/meminfo | awk '{print $2}')"
            HP_TOTAL="$(grep HugePages_Total /proc/meminfo | awk '{print $2}')"
            HP_FREE="$(grep HugePages_Free /proc/meminfo | awk '{print $2}')"
            HP_RSVD="$(grep HugePages_Rsvd /proc/meminfo | awk '{print $2}')"
            HP_USED="$((HP_TOTAL-HP_FREE+HP_RSVD))"
            TOTALMEM="$((RSS+(HP_USED*HP_SIZE)))"
            echo " - HugePage Usage     : $((HP_USED*(HP_SIZE/1024))) Mb ($HP_USED HugePages)"
            echo " - Total Memory Usage : $((TOTALMEM/1024)) Mb ($TOTALMEM kb)"
        fi

        echo " - Active Connections : "
        netstat -tna | grep --color=never -E "Proto|$SERVERPORT"
    else
        echo "$SERVERNAME is not running. Unable to give info."
        exit 1
    fi
}
