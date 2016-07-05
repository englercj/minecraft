# Minecraft control scripts

Tested with spigot v1.10.2.

## Features

- Base commands (start/stop/restart/reload)
- Support ramdisk for worlds
- Backups for worlds, servers, and logs
- Updating for spigot servers

## Requirements

- screen
- rsync
- curl
- java 8
- git

## Installation

Be sure to replace `USERNAME` with the non-root user you want to run your scripts and edit your configs.

```
curl -o- https://raw.githubusercontent.com/englercj/minecraft/master/install.sh | bash -s USERNAME
```

## TODO:

- Fresh install of server script
 * EULA handling
 * Moving worlds into proper folders
 * setting common properties
- Installing spigot plugins
