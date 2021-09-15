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
    [ -d "$installingLocation$1" ];
}
getGameVersion() {
    cd ../$repoName;
    version=$(git branch --show-current);
    cd - > /dev/null;
}

# VARIABLES
installingLocation="/home/$USER/.games/";
gameName="";
repoName="";
fullName="";
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
    repoName=$2;
else
    ask "Name of the repository?"
    repoName=$askResponse;
fi

# Check location to store the games exist
if [ ! -d "$installingLocation" ]; then
    mkdir $installingLocation;
    echo "Created location to install the games: $installingLocation"
fi

# Confirm action
# ask "The script is about to $mode the game $gameName $version. Do you want to continue?" "[yes]";
# if [ ! $askResponse = "yes" ]; then
#     error "Aborted";
# fi


getGameVersion; # version stored on variable 'version'
fullName=$repoName\_$version; # Full name of the repository
gameName=$(echo $repoName | sed -e 's/PY\-//' -e 's/[\-_]/ /g');

case $mode in
    install)
        if gameIsInstalled $fullName; then
            error "The game $fullName is already installed."
        fi

        echo "Installing $gameName, $version version.";

        # Create the game folder with the code
        mkdir $installingLocation$fullName;
        cp ../$repoName/* $installingLocation$fullName/ -r;

        echo "cd $installingLocation$fullName/; python3 main.py;" > $installingLocation$fullName/play.sh;
        chmod 755 $installingLocation$fullName/play.sh

        echo "[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=$gameName
Comment=Made by Jkutkut
Exec=$installingLocation$fullName/play.sh
Icon=$installingLocation$fullName/Res/logo.png
Terminal=false" >> $fullName.desktop && # create the .desktop file

        sudo mv $fullName.desktop /usr/share/applications/
        echo "Game installed!";
        ;;
    update)
        # if ! gameIsInstalled $gameName; then
        #     error "$gameName isn't installed on this device.";
        # fi
        
        # ! Temporal hardcoding unistall
        rm -rf $installingLocation$fullName;
        sudo rm /usr/share/applications/$fullName.desktop;

        # echo "Updating $gameName.";
        
        # echo "Game udated.";
        ;;
    unistall)
        if ! gameIsInstalled $fullName; then
            error "$fullName isn't installed on this device.";
        fi

        echo "unistalling...";

        echo "game removed";
        ;;
    *)
        error "The mode is not valid";
esac