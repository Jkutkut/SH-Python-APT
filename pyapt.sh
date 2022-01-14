#!/bin/sh

# VARIABLES
installingLocation="/home/$USER/.games/";
gameName="";
repoName="";
fullName="";
mode=""; # install, unistall, update

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
askResponse="" #When executing the function ask(), the response will be stored here
ask() { # to do the read in terminal, save the response in askResponse
	text=$1
	textEnd=$2
	read -p "$(echo ${LBLUE}"$text"${NC} $textEnd)->" askResponse
}
selection="" #When executing the funtion selectionMenu(), the result will be stored here
selectionMenu() { #allows to create a selection menu. arguments: "template" "op1 opt2..." "skip"
	elements=$2
	skipElement=$3

	# Show elements
	echo "Select a $1:"
	l=-1
	for t in $elements; do
		if [ "$t" = "$skipElement" ]; then
			continue
		fi
		l=$((l + 1))
		echo " - ${YELLOW}$l${NC} $t"
	done

	# Ask for the wanted element
	ask "Wanted $1" "[0-$l]"
	option=$askResponse
	if expr "$option" : '[0-9][0-9]*$'>/dev/null &&
		[ $option -ge 0 ] && [ $option -le $l ]; then
		# If option is valid, find the option name
		l=0
		for t in $elements; do
			if [ $l -eq $option ]; then
				selection=$t # Store it here
				return
			fi
			l=$((l + 1))
		done
	else
		echo "${YELLOW}Invalid response${NC}\n"
		selectionMenu "$1" "$2" "$3"
	fi
	unset elements skipElement
}
error() { # function to generate the error messages. If executed, ends the script.
	err=$1;
	echo "${RED}~~~~~~~~  ERROR ~~~~~~~~
	$1${NC}";
	exit 1
}


# Getters
gameIsInstalled() { # Checks if the given game is currently installed on the device
	[ -d $installingLocation$1 ];
}
getGameVersion() {
	if [ -d $repoName ]; then
		cd ./$repoName
	else
		cd ../$repoName
	fi

	version=$(git branch --show-current)
	cd - > /dev/null
}
getRepoName() {
	# Get, select and store the name of the desired repo in the current dir (or parent)
	if [ ! -z $1 ]; then # If 2º argument given
		repoName=$1;
	else
		ls ${PWD}/PY* > /dev/null 2>&1 && # If Python repos on the current directory
		avalibleRepos=$(ls -d1 PY*) || # Store their names
		{ # Else, attempt to get them from the parent directory
			ls ${PWD}/../PY* > /dev/null 2>&1 &&
			avalibleRepos=$(ls -d1 ../PY*) ||
			error "Not games avalible to be installed";
		}
		selectionMenu "repository" "$avalibleRepos" ""
		repoName=$askResponse;
	fi
}

# SETUP
# Check location to store the games exist
if [ ! -d "$installingLocation" ]; then
	mkdir $installingLocation;
	echo "Created location to install the games: $installingLocation"
fi

# Get mode and gameName
case $1 in
	install|unistall|update)
		mode="$1"
		;;
	*)
		selectionMenu "mode" "install unistall update" ""
		mode=$selection
		;;
esac
echo "Mode selected: ${YELLOW}$mode${NC}\n"
case $mode in
	install)
		getRepoName "$2" # get the repository to use in current directory or the one given as argument

		# Confirm action
		ask "The script is about to $mode the game $repoName.\nDo you want to continue?" "[yes]";
		if [ ! $askResponse = "yes" ]; then
			error "Aborting $mode of $repoName";
		fi

		getGameVersion; # version stored on variable 'version'
		fullName=$repoName\_$version; # Full name of the repository
		gameName=$(echo $repoName | sed -e 's/PY\-//' -e 's/[\-_]/ /g');


		if gameIsInstalled $fullName; then
			error "The game $fullName is already installed."
		fi

		echo "Installing $gameName, $version version.";

		# Create the game folder with the code
		mkdir $installingLocation$fullName;
		if [ -d $repoName ]; then 
			cp ./$repoName/* $installingLocation$fullName/ -r;
		else
			cp ../$repoName/* $installingLocation$fullName/ -r;
		fi

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
		#if [ ! -z $2 ]; then # If 2º argument given
		#	repoName=$2;
		#else # Get repository name
		#	avalible=$(cd ../;ls -d1 PY*; cd - > /dev/null;);
		#	echo "Avalible repositories:";
		#	for a in $avalible; do # For all games avalible to install, check if installed
		#		if gameIsInstalled "$a"*; then
		#			echo "- $a";
		#		fi
		#	done
		#	ask "Name of the repository?"
		#	repoName=$askResponse;
		#fi
		# TODO show only the installed and avalibles repos
		# getRepoName "$2" # get the repository to use in current directory or the one given as argument

		if ! gameIsInstalled "$repoName"*; then # If game not installed (any version)
			error "$repoName not installed on this device.";
		fi

		# Confirm action
		ask "The script is about to $mode the game $repoName.\nDo you want to continue?" "[yes]";
		if [ ! $askResponse = "yes" ]; then
			error "Aborted";
		fi
		
		echo "Updating $repoName.";

		echo "Removing old version" &&
		./pyapt.sh unistall $repoName | sed -e 's/^/  /' &&

		echo "Installing new version" &&
		./pyapt.sh install $repoName | sed -e 's/^/  /' &&
		
		echo "Game updated!" ||

		error "Not able to update.";
		;;
	unistall)
		if [ $(ls $installingLocation -1 | wc -l) -eq 0 ]; then # Check if games installed
			error "There aren't any games installed on this device";
		fi

		if [ ! -z $2 ]; then # If 2º argument given
			cd $installingLocation;
			repoName=$(ls -d1 "$2"*);
			cd - > /dev/null;
		else
			echo "Installed games:\n$(ls -1 $installingLocation | sed -e 's/^/- /')\n";
			ask "Which game do you want to remove?"
			repoName=$askResponse;
		fi

		if ! gameIsInstalled $repoName; then
			error "$repoName isn't installed on this device.";
		fi

		# Confirm action
		ask "The script is about to $mode the game $repoName.\nDo you want to continue?" "[yes]";
		if [ ! $askResponse = "yes" ]; then
			error "Aborted";
		fi

		echo "Unistalling $repoName...";
		rm -rf $installingLocation$repoName;
		sudo rm /usr/share/applications/$repoName.desktop
		echo "Game removed";
		;;
	*)
		error "The mode is not valid";
esac
