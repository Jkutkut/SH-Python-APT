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

# VARIABLES
installingLocation="/home/$USER/.games/";
gameName="";
mode="install"; # install, unistall, update


# Change the mode based on the arguments
while [ ! -z $1 ]; do # While the are avalible arguments
    v=""; # Variable to change
    vContent=""; # Value to asing to the variable
    q=""; # Question to tell the user if no further arguments given

    case $1 in
        install)
            echo "install mode";
            v="mode";
            vContent="install";
            ;;
        unistall)
            echo "unistall mode";
            v="mode";
            vContent="unistall";
            ;;
        update)
            echo "update mode";
            v="mode";
            vContent="update";
            ;;
        *)
            error "Invalid argument";
    esac

    shift; # -ANY argument removed
        
    # if [ $(expr match "$1" ^\(-.+\)?$) ]; then # If not given
    #     ask "$q" ""; # Ask for it
    #     vContent=$askResponse; # The response is the content
    # else
    #     vContent=$1; # Next argument is the content
    #     shift;
    # fi

    # eval $v="$vContent";
done

if [ ! -d "$installingLocation" ]; then
    mkdir $installingLocation;
    echo "Created location to install the games: $installingLocation"
fi

case $mode in
    install|update)
        gameName=${PWD##*/};

        # ask "The script is about to $mode the game $gameName. Do you want to continue?" "[yes]";

        # if [ ! $askResponse = "yes" ]; then
        #     error "Aborted";
        # fi

        version=$(git branch –show-current);

        echo "Installing $version version of $gameName...";
        

        
        echo "Done!";
        ;;
    unistall)
        echo "unistalling...";
        echo "game removed";
        ;;
    *)
        error "The mode is not valid";
esac