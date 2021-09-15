#!/bin/sh

#colors:
NC='\033[0m' # No Color
RED='\033[0;31m'
GREEN='\033[0;32m'
LRED='\033[1;31m'
LGREEN='\033[1;32m'
YELLOW='\033[1;33m'
LBLUE='\033[1;34m'
TITLE='\033[38;5;33m'


askResponse=""; #When executing the function ask(), the response will be stored here
ask() { # to do the read in terminal, save the response in askResponse
    text=$1;
    textEnd=$2;
    read -p "$(echo ${LBLUE}"$text"${NC} $textEnd)->" askResponse;
}
error() { # function to generate the error messages. If executed, ends the script.
    err=$1;
    echo "${RED}~~~~~~~~  ERROR ~~~~~~~~
    $1${NC}";
    exit 1
}
gameIsInstalled() { # Checks if the given game is currently installed on the device
    name=$1;
    if [ -d "$installingLocation$name" ]; then
        true;
    else
        false;
    fi
}

# VARIABLES
installingLocation="/home/$USER/.games/";
gameName="";
mode=""; # install, unistall, update


# Get mode and gameName
case $1 in
    install)
        mode="install";
        ;;
    unistall)
        mode="unistall";
        ;;
    update)
        mode="update";
        ;;
    *)
        error "Invalid argument";
esac

if [ ! -z $2 ]; then
    gameName=$2;
else
    ask "Name of the repository: "
    gameName=$askResponse;
fi

# Check location to store the games exist
if [ ! -d "$installingLocation" ]; then
    mkdir $installingLocation;
    echo "Created location to install the games: $installingLocation"
fi


version=$(git branch --show-current);

# ask "The script is about to $mode the game $gameName $version. Do you want to continue?" "[yes]";
# if [ ! $askResponse = "yes" ]; then
#     error "Aborted";
# fi

case $mode in
    install)
        if gameIsInstalled $gameName; then
            error "The game $gameName is already installed."
        fi

        echo "Installing $version version of $gameName...";

        echo "Game installed!";
        ;;
    update)
        if ! gameIsInstalled $gameName; then
            error "There's no game called $gameName installed on this device.";
        fi

        echo "Updating $gameName.";
        
        echo "Game udated.";
        ;;
    unistall)
        if ! gameIsInstalled $gameName; then
            error "There's no game called $gameName installed on this device.";
        fi

        echo "unistalling...";
        
        echo "game removed";
        ;;
    *)
        error "The mode is not valid";
esac