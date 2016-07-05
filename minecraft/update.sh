##
# Checks for updates to spigot build tools
##
check_update_spigot_build_tools() {
    NEW_REVISION=`curl -v -s $URL_CONSOLE_TEXT 2>&1 | grep "Checking out Revision" | awk '{print $4}'`
    CUR_REVISION=`cat $BUILD_PATH/revision.txt`

    if [ NEW_REVISION == CUR_REVISION ]; then
        echo "Already on the latest version!"
        return 1
    fi

    return 0
}

##
# Updates spigot build tools
##
update_spigot_build_tools() {
    cd $BUILD_PATH
    as_user "curl -o BuildTools.jar $URL_BUILD_TOOLS"
    as_user "echo $NEW_REVISION > revision.txt"
}

##
# update spigot
##
update_spigot() {
    cd $BUILD_PATH
    as_user "rm craftbukkit-*.jar spigot-*.jar"
    as_user "java -jar BuildTools.jar --rev latest"
    as_user "cp -v craftbukkit-*.jar $SERVER_PATH/craftbukkit.jar"
    as_user "cp -v spigot-*.jar $SERVER_PATH/$SERVICE"
}

##
# Updates the minecraft server
##
mc_update() {
    if check_update_spigot_build_tools; then
        update_spigot_build_tools
    fi

    update_spigot
}
