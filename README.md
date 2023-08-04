# VSC-Update

A shell script that replace portable[^1] VSCode installations from a vscode `tar.gz` archive. The script doesn't check the version information of the current installation and that from the provided archive, so it can be used to upgrade/downgrade current installations.

The script makes some assumptions:

1- VSCode installations are under the same root directory, pointed at by the environment variable `VSCODE_HOME`.

2- if `VSCODE_HOME` is not defined, it's assumed that the portable installations are under directory `~/VSCode/`.

> Default VSCODE_HOME value can be changed by changing the variable VSCODE_HOME_DEFAULT in the script

3- Each VSCode installation is in a separate direcory, and the directory contains `VSCode` in its name, eg: `VSCode python`, `VSCode_JS`, `VSCode-data-science` are all valid names and recognizable by the script as VSCode installation.

> - Installation name doesn't have to start with `VSCode`, it can be anywhere in the installation name
> - The script uses the variable `VSCODE_INSTALLATION_NAME_SLUG` to look for VSCode installation directories. It's default value is `VSCode`, you can change it in the script to whatever suits you.
> - The script uses looks for installations in `VSCODE_HOME` using the command: `ls "$VSCODE_HOME" | grep "$GREP_OPTIONS" "$VSCODE_INSTALLATION_NAME_SLUG"`. It's possible to pass options to grep for a customized lookup, eg: `-E, -i`, etc.

4- The script assumes the following nested directory structure:

```text
$VSCODE_HOME/
    |-- VSCode {installation_name}/
    |---- code.png
    |---- {VSCODE_INSTALL_NAME}/
    |------ data/
    |
    |-- VSCode {installation_name}/
    |---- code.png
    |---- {VSCODE_INSTALL_NAME}/
    |------ data/
    |-- .
    |-- .
    |-- .
    |-- .
```

> - `VSCODE_INSTALL_NAME` is the name of the directory that contains VSCode installation files and folders. Its name differs depending on the installation, eg: for linux-x64 it's named `VSCode-linux-x64`. Default value is `VSCode-linux-x64`. 
> - Change the variable `VSCODE_INSTALL_NAME` to the value that suits your installation. It must match the directory name inside vscode archive `code-version.tar.gz`.
> - `code.png` is a custom icon for that installation. If found, it will be copied to replace default VSCode icon (currently fund in `$VSCODE_DIR/resources/app/resources/linux`)
> - Each portable installation contains a `data` directory (installation's portable data, eg: extensions, settings, etc). The data directory is moved into the installation's parent director (`VSCcode {installation_name}`) before updating the installation, then moved back into the installation directory after the update.
> - During update, the old `VSCODE_INSTALLATION_NAME` directory is deleted, then replaced with the new director from the deflated VSCode archive.

## Usage:

### Install VSCode from archive

```term
./vscode_update.sh path/to/code-stable-version_number.tar.gz
```

### Help

```term
./vscode_update.sh -h
```

```text
./vscode_update.sh path/to/code-stable-version_number.tar.gz
Unpacks given vscode.tar.gz and copies it into VSCode installations under VSCODE_HOME
Uses VSCODE_HOME enviroment variable to look for VSCode installations
Assumes the following directory structure:
VSCODE_HOME/
    |
    |-- Install/
    |-- VSCodeXXX
          |-- VSCode-linux-x64
                |-- data
    |-- VSCODEYYY
          |--VSCode-linux-x64
                |-- data
    .
    .
    .

Each VSCode installation ahs a parent directory, name VSCode[suffix].
The parent directory contains a VSCode-linux-x64 direcotry, that contains VSCode files.
In VSCode-linux-x64, a 'data' directory (where 'user-data', 'extensions' and 'tmp') that is moved into the VSCode installation parent directory (VSCode[suffix]), then moved back.
```

## Notes

[^1]: To install a portable version of VSCode, or make a current installation portable, check this [link](https://code.visualstudio.com/docs/editor/portable)

