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
    cd $BUILD_PATH && curl -o BuildTools.jar $URL_BUILD_TOOLS
}

##
# update spigot
##
update_spigot() {
    cd $BUILD_PATH &&
    rm craftbukkit-*.jar spigot-*.jar &&
    java -jar BuildTools.jar --rev latest &&
    cp craftbukkit-*.jar $SERVER_PATH/craftbukkit.jar
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
