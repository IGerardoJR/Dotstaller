# The following script should be used to uninstall BSPWM and all of his dependencies.

# Defining colors to make a colorful output in the terminal
redColor="\e[1;31m   \b\e   "
resetColor="\e[1;0m   \b\e   "
greenColor="\e\b[1;32m   \b\e   "
yellowColor="\e[1;33m   \b\e   "
blueColor="\e[1;34m   \b\e   "

# Variables to make easier handle paths
configPath=$HOME/.config/ # Path where configs are gonna put
switchHome="cd $HOME" # switch to home user path

echo -e "${yellowColor}\The following script are going to uninstall dotfiles and all of his dependencies.This may take time(5 minutes)"
sleep 4

# find a file or folder and do something pending the result.
function existsItem {
    if test $1 $2
    then
        $3
    else
        $4
    fi
}

deps=("bspwm" "sxhkd" "rofi" "polybar")
function deleteBinaries {
    echo -e "$yellowColor\Deleting dependencies. This may take time $resetColor"
    sleep 2
    for dl in "${deps[@]}"
    do
         echo -e "$redColor\Deleting $dl $resetColor"
         existsItem "-f" "$dl" "`sudo pacman -R $dl --noconfirm`" ""
         sleep 2
    done
} 

function deleteConfigurations {
    cd $configPath
    echo -e "$blueColor\Deleting configurations files...$resetColor"
    for folders in "${deps[@]}"
    do
        existsItem "-d" "$folders" "`rm -r $folders`" ""
        sleep 2
    done
    echo -e "$greenColor\Items deleted$resetColor"
    sleep 1
}


# Calling the methods
deleteBinaries
deleteConfigurations
# deleting the .xinitrc file
$switchHome
existsItem "-f" ".xinitrc" "`rm .xinitrc && echo &>/dev/null`" "`echo &>/dev/null`"
echo -e "${yellowColor}\Uninstall completed, you might reboot the system ${colorReset}"
echo "Good bye!"
sleep 2






