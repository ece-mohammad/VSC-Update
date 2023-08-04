#!/bin/bash

# -----------------------------------------------------------------------------
# Default values
# -----------------------------------------------------------------------------
VSCODE_HOME_DEFAULT="$HOME/VSCode"
VSCODE_INSTALLATION_NAME_SLUG="VSCode"
GREP_OPTIONS=""
VSCODE_INSTALL_NAME="VSCode-linux-x64"

# VSCode icon
ICON_NAME="code.png"
ICON_PATH="resources/app/resources/linux"

# -----------------------------------------------------------------------------
# global variables
# -----------------------------------------------------------------------------
tempfiles=()


# -----------------------------------------------------------------------------
# Functions
# -----------------------------------------------------------------------------

Usage() {
  echo "Usage: $0 path/to/code-stable-version_number.tar.gz"

}


Help() {
  echo "Unpacks given vscode.tar.gz and copies it into VSCode installations under VSCODE_HOME"
  echo "Uses VSCODE_HOME enviroment variable to look for VSCode installations"
  echo "Assumes the following directory structure:"
  echo "VSCODE_HOME/"
  echo "    |"
  echo "    |-- Install/"
  echo "    |-- VSCodeXXX"
  echo "          |-- VSCode-linux-x64"
  echo "                |-- data"
  echo "    |-- VSCODEYYY"
  echo "          |--VSCode-linux-x64"
  echo "                |-- data"
  echo "    ."
  echo "    ."
  echo "    ."
  echo ""
  echo "Each VSCode installation ahs a parent directory, name VSCode[suffix]."
  echo "The parent directory contains a VSCode-linux-x64 direcotry, that contains VSCode files."
  echo "In VSCode-linux-x64, a 'data' directory (where 'user-data', 'extensions' and 'tmp') that is moved into the VSCode installation parent directory (VSCode[suffix]), then moved back."
  echo ""
}


Unpack() {
  if [[ -n "$1" ]]; then
    tar -xvf "$1"
    echo ""
  else 
    exit 1;
  fi 
}


AddTemp() {
  tempfiles+=( "$1" )
}


Cleanup() {
  for tmp in ${tempfiles[@]}; do 
    echo "Removing file: $tmp"
    rm -rf "$tmp"
  done 
}


CheckNoArgs() {
  if [[ -z "$1" ]]; then
    Usage
    exit
  fi
}


CheckHelpArgs() {
  if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then 
    Usage 
    Help 
    exit 
  fi
}

CheckArchiveFile() {
  if [[ -f "$1" ]] && [[ -s "$1" ]] ; then 
    return 1
  else 
    echo "$1: is not a file, or doe not exist"
  fi
}


SetVSCodeHome() {
  # check if VSCODE_HOME is not set
  if [[ -z "$VSCODE_HOME" ]]; then 
    VSCODE_HOME="$VSCODE_HOME_DEFAULT"

  # check if VSCODE_HOME is a directory 
  elif [[ ! -d "$VSCODE_HOME" ]]; then
    echo "VSCODE_HOME doesn't exist or is not a directory: VSCODE_HOME=$VSCODE_HOME"
    exit
  fi
}


GetVSCodeInstallations() {
  # get VSCode installations in VSCODE_HOME and 
  # append installations to VSCODE_INSTALLS
  # Installations directories are saved in the array VSCODE_INSTALLS 

  VSCODE_INSTALLS=()

  # get VSCode install directories
  vscode_installations=$( ls $VSCODE_HOME | grep $GREP_OPTIONS $VSCODE_INSTALLATION_NAME_SLUG )
  for install in ${vscode_installations[@]}; do
    VSCODE_INSTALLS+=( "$VSCODE_HOME/$install" )
  done

  return ${#VSCODE_INSTALLS[@]}
}

# -----------------------------------------------------------------------------
# Arguments
# -----------------------------------------------------------------------------

# check if no arguments were given 
CheckNoArgs "$1" 

# check for help
CheckHelpArgs "$1"

# check if given archive exists 
CheckArchiveFile "$1"

# -----------------------------------------------------------------------------
# VSCODE_HOME
# -----------------------------------------------------------------------------
SetVSCodeHome 

echo "VSCODE_HOME=$VSCODE_HOME"

# -----------------------------------------------------------------------------
# VSCode Installations 
# -----------------------------------------------------------------------------
GetVSCodeInstallations 

ret=$?
if [[ $ret -eq 0 ]]; then 
  echo "Didn't find any VSCode installations in $VSCODE_HOME"
  exit 
fi

for vscode in ${VSCODE_INSTALLS[@]}; do 
  echo Found VSCode installation: $vscode
done

NEW_VSCODE="$PWD/VSCode-linux-x64"

# -----------------------------------------------------------------------------
# Unpack VSCode archive 
# -----------------------------------------------------------------------------
# unpack vscode
echo "Preparing files for update..."
echo Unpacking "$1"
Unpack "$1"

# add VSCODE_INSTALL_NAME to tempfiles 
AddTemp "$VSCODE_INSTALL_NAME"

# -----------------------------------------------------------------------------
# Update existing installations 
# -----------------------------------------------------------------------------

for dir in ${VSCODE_INSTALLS[@]}; do 
  
  echo "Updating install in: $dir"

  # backup data dir 
  echo "Backing up data directory to $dir/data"
  mv -t "$dir" "$dir/$VSCODE_INSTALL_NAME/data"

  # remove old VSCode-linux-x64 dir
  echo "Removing old VSCode install: $dir/$VSCODE_INSTALL_NAME"
  rm -rf "$dir/$VSCODE_INSTALL_NAME"

  # copy new version VSCode-linux-x64 into vscode dir 
  echo "Copying new VSCode install to: $dir/$VSCODE_INSTALL_NAME"
  cp -r -t "$dir" "$NEW_VSCODE" 

  # move data dir into VSCode-linux-x64 
  echo "Adding back data direcotry"
  mv -t "$dir/$VSCODE_INSTALL_NAME" "$dir/data"
 
  # check for modified icon
  if [ -f "$dir/$ICON_NAME" ]
  then
    echo "Copying icon into $dir/$VSCODE_INSTALL_NAME/$ICON_PATH"
    cp -t "$dir/$VSCODE_INSTALL_NAME/$ICON_PATH" "$dir/$ICON_NAME"
  fi 

  echo "-------------------------------------"

done

echo ""
echo "Cleaning up files..."
Cleanup 

echo "Done!"


