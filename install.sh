#!/usr/bin/env bash

{ # this ensures the entire script is downloaded before execution #

USER=$1
TEMP="/tmp"
DIR="$TEMP/minecraft-scripts"
REPO="https://github.com/englercj/minecraft.git"

if [ -z $USER ]; then
    echo "Usage: $0 <username>"
    exit 1
fi

# Clone to temp dir
clone_repo() {
    echo "Downloading from git to '$DIR'" &&
    rm -rf $DIR &&
    mkdir -p "$DIR" &&
    command git clone "$REPO" "$DIR"
}

# move into temp directory
copy_files() {
    echo "Installing files..." &&
    cd "$DIR" &&
    mkdir -p /etc/minecraft &&
    mv -v ./default/* /etc/default/ &&
    mv -v ./init.d/* /etc/init.d/ &&
    mv -v ./minecraft/* /etc/minecraft/ &&

    echo "Setting permissions..." &&
    chown $USER /etc/minecraft &&
    chown $USER /etc/minecraft/* &&
    chown $USER /etc/default/minecraft &&
    chmod +x /etc/init.d/minecraft
}

clone_repo && copy_files && echo "Installed!"

} # this ensures the entire script is downloaded before execution #
