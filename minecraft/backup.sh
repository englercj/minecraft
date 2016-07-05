##
# Sets some env vars based on backup format.
##
check_backup_settings() {
    case "$BACKUP_FORMAT" in
        tar)
            COMPRESSCMD="tar -hcjf"
            STORECMD="tar -cpf"
            ARCHIVEENDING=".tar.bz2"
            STOREDENDING=".tar"
            ;;
        zip)
            COMPRESSCMD="zip -rq"
            STORECMD="zip -rq -0"
            ARCHIVEENDING=".zip"
            STOREDENDING=".zip"
            ;;
        *)
            echo "$BACKUPFORMAT is not a supported backup format"
            exit 1
            ;;
    esac
}

##
# Performs a backup of the worlds
##
mc_world_backup() {
    check_backup_settings
    get_worlds
    today="`date +%F`"
    as_user "mkdir -p $WORLD_BACKUP_PATH"

    # Check if the backup script compatibility is enabled
    if [ "$BACKUP_SCRIPT_COMPATIBLE" == true ]; then
        # If it is enabled, then delete the old backups to prevent errors
        echo "Detected that backup script compatibility is enabled, deleting old backups that are not necessary."
        as_user "rm -r $WORLD_BACKUP_PATH/*"
    fi

    for INDEX in ${!WORLDNAME[@]}; do
        echo "Backing up minecraft ${WORLDNAME[$INDEX]}"

        # If this is set tars will be created compatible to WorldEdit
        if [ "$WORLD_EDIT_COMPATIBLE" == true ]; then
            as_user "mkdir -p $WORLD_BACKUP_PATH/${WORLDNAME[$INDEX]}"
            path=`datepath $WORLD_BACKUP_PATH/${WORLDNAME[$INDEX]}/ $ARCHIVEENDING $ARCHIVEENDING`

        # If is set tars will be put in $WORLD_BACKUP_PATH without any timestamp to be compatible with
        # [backup rotation script](https://github.com/adamfeuer/rotate-backups)
        elif [ "$BACKUP_SCRIPT_COMPATIBLE" == true ]; then
            path=$BACKUPPATH/${WORLDNAME[$INDEX]}$ARCHIVEENDING

        # Normal backup
        else
            as_user "mkdir -p $WORLD_BACKUP_PATH/${today}"
            path=`datepath $WORLD_BACKUP_PATH/${today}/${WORLDNAME[$INDEX]}_ $ARCHIVEENDING $ARCHIVEENDING`
        fi

        # Don't store the complete path
        if [ "$WORLD_EDIT_COMPATIBLE" == true ]; then
            as_user "cd $SERVER_PATH && $COMPRESSCMD $path ${WORLDNAME[$INDEX]}"
        else
            as_user "$COMPRESSCMD $path $SERVER_PATH/${WORLDNAME[$INDEX]}"
        fi
    done
}

##
# Performs a backup of the server
##
mc_server_backup() {
    check_backup_settings
    echo "Backing up server into $SERVER_BACKUP_PATH"
    path=`datepath $SERVER_BACKUP_PATH/mine_`
    as_user "mkdir -p $path"

    if [ "$COMPRESS_SERVER_BACKUP" == true ]; then
        as_user "$COMPRESSCMD $path/whole-backup$ARCHIVEENDING $SERVER_PATH"
    else
        as_user "$STORECMD $path/whole-backup$STOREDENDING $SERVER_PATH"
    fi
}

##
# Performs a backup of the logs
mc_log_backup() {
    check_backup_settings
    path=`datepath $LOG_BACKUP_PATH/logs_ $ARCHIVEENDING`
    as_user "mkdir -p $path"

    shopt -s extglob
    as_user "cp $LOG_PATH $path"

    # only if previous command was successful
    if [ $? -eq 0 ]; then
        # truncate the existing log without restarting server
        as_user "cp /dev/null $FILE"
        as_user "echo \"Previous logs rolled to $path\" > $FILE"
    else
        echo "Failed to rotate log from $FILE into $path"
    fi

    as_user "$COMPRESSCMD $path$ARCHIVEENDING $path"
    if [ $? -eq 0 ]; then
        as_user "rm -r $path"
    fi
}
