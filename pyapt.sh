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


# FUNCTIONS
askResponse=""; #When executing the function ask(), the response will be stored here
ask() { # to do the read in terminal, save the response in askResponse
    text=$1;
    textEnd=$2;
    read -p "$(echo ${LBLUE}"$text"${NC} $textEnd)->" askResponse;
};
error() { # function to generate the error messages. If executed, ends the script.
    err=$1;
    echo "${RED}~~~~~~~~  ERROR ~~~~~~~~
    $1${NC}";
    exit 1
};

# Getters
gameIsInstalled() { # Checks if the given game is currently installed on the device
    [ -d $installingLocation$1 ];
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

# SETUP
# Check location to store the games exist
if [ ! -d "$installingLocation" ]; then
    mkdir $installingLocation;
    echo "Created location to install the games: $installingLocation"
fi

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
        error "Invalid mode. It must be install, unistall or update";
esac

case $mode in
    install)
        if [ ! -z $2 ]; then # If 2º argument given
            repoName=$2;
        else
            echo "Avalible games:\n$(cd ..; ls -d1 PY* | sed -e 's/^/- /'; cd - > /dev/null;)";
            ask "Name of the repository?"
            repoName=$askResponse;
        fi

        # Confirm action
        # ask "The script is about to $mode the game $gameName $version. Do you want to continue?" "[yes]";
        # if [ ! $askResponse = "yes" ]; then
        #     error "Aborted";
        # fi

        getGameVersion; # version stored on variable 'version'
        fullName=$repoName\_$version; # Full name of the repository
        gameName=$(echo $repoName | sed -e 's/PY\-//' -e 's/[\-_]/ /g');


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
        if [ ! -z $2 ]; then # If 2º argument given
            repoName=$2;
        else # Get repository name
            avalible=$(cd ../;ls -d1 PY*; cd - > /dev/null;);
            echo "Avalible repositories:";
            for a in $avalible; do # For all games avalible to install, check if installed
                if gameIsInstalled "$a"*; then
                    echo "- $a";
                fi
            done

            ask "Name of the repository?"
            repoName=$askResponse;
        fi

        if ! gameIsInstalled "$repoName"*; then # If game not installed (any version)
            error "$repoName not installed on this device.";
        fi
        
        echo "Updating $gameName.";

        echo "Removing old version";
        # ./pyapt.sh unistall
        echo "Installing new version";
        
        echo "Game udated.";
        ;;
    unistall)
        len=$(ls $installingLocation -1 | wc -l);
        if [ $len -eq 0 ]; then
            error "There aren't any games installed on this device";
        fi

        echo "Installed games:\n$(ls -1 $installingLocation | sed -e 's/^/- /')\n";

        ask "Which game do you want to remove?"
        repoName=$askResponse;

        if ! gameIsInstalled $repoName; then
            error "$repoName isn't installed on this device.";
        fi

        echo "Unistalling $repoName...";
        rm -rf $installingLocation$repoName;
        sudo rm /usr/share/applications/$repoName.desktop
        echo "Game removed";
        ;;
    *)
        error "The mode is not valid";
esac