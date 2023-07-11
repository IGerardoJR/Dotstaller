# Dotstall v1.1
# Made by : IGerardoJR
# https://github.com/IGerardoJR/dotstall
# [**********************************************************************************************]
# Global variables
# Defining colors to make a colorful output in the terminal
redColor="\e[1;31m   \b\e   "
resetColor="\e[1;0m   \b\e   "
greenColor="\e\b[1;32m   \b\e   "
yellowColor="\e[1;33m   \b\e   "
blueColor="\e[1;34m   \b\e   "
# Variables to make easier to handle paths
configPath=$HOME/.config/ # Path where configs are gonna put
fontPath=/usr/share/fonts # Path to install the downloaded fonts
pathImages=$HOME/.draggedImage # Path to save the initial image on bspwm
switchHome="cd $HOME" # switch to home user path
# [**********************************************************************************************]
# Welcome output

echo  "Dotstall v1.0.0"
sleep 1
echo  "Script made by: IGerardoJR"
echo -e "${yellowColor}\WARNING: This script just works with ${blueColor}Arch Linux and based distros  ${resetColor}"
sleep 3
# ----------------------------------------------------------------------------------------------------------
# Stage 1 : Verify dependencies & install missing
# Declaring two arrays to split the dependencies
depsFound=()
depsNotFound=()
# Setting up a counter for missing dependencies to deploy a warning message
counterNotFound=0
# Setting an array with the necessary dependencies
dependencies=("bspwm" "sxhkd" "rofi" "nitrogen" "git" "wget" "polybar" "wmname")
function lookDependencies {
    echo -e "${blueColor}\Verifying current dependencies ${resetColor}"
    for i in "${dependencies[@]}"
    do
        # Usually execs of dependencies are allocated in the folder /usr/bin folder
        searchDeps="find /usr/bin/$i" 
        $searchDeps &>/dev/null
       
    # Comparing if a dependencie was found or not.
    if [[ $? -eq 0 ]]
    then
        depsFound+=($i)
    else
        depsNotFound+=($i)
        counterNotFound+=1
    fi
    done
}

# Looking for missing dependencies
echo -e "$yellowColor\Looking for missing dependencies $resetColor"
# Is gonna analize on /usr/bin/ the missing or installed current dependencies
lookDependencies

# Printing the missing dependencies
    for notFound in "${depsNotFound[@]}"
    do
        echo -e "$redColor\[-] $notFound $resetColor"
        sleep 2
    done

    # Printing the found dependencies
    for found in "${depsFound[@]}"
    do
        echo -e "$greenColor\[+] $found $resetColor"
        sleep 2
    done

# Based on the arrays, we're gonna drag the missing dependencies from dnf repos
function getDependecies {
    for missing in ${depsNotFound[@]}
    do
        sudo apt-get install $missing -y &>/dev/null
    # if    success
    if [[ $? == 0 ]]
    then
        # Success Message
        echo -e "$greenColor\[+] $missing installed $resetColor"
        counterNotFound=counterNotFound-1 
    sleep 1
    else
        # Warning Message
       echo -e "$redColor \couldn't find $missing $resetColor"
    sleep 1
    fi
    done
}

# evaluating if all dependencies are satisficied
function isMissingSomething {
    if [[ $counterNotFound -gt 0 ]]
    then
        echo -e "$yellowColor\WARNING: One or more dependencies missing, trying to install them. ${resetColor}"
        sleep 1
        getDependecies
    fi
}
# if a missing dependencie, is going to find and install it.
isMissingSomething
# ----------------------------------------------------------------------------------------------------
# Stage 2 : Copying and installing configuration files into user system.
function exiItem {
    if test $1 $2
    then
        $3
    else
        $4
    fi
}

# Backup folder is gonna be created just in case we had one or more folders 


function backupIfExist {
    cd $configPath
    # mkdir "backup"
    exiItem "-d" "backup" "" "`mkdir backup`"
    for folder in ${dependencies[@]}
    do
    # If folders in .config path already exists
    # if test -d "${configPath}$folder"
    # then
    #     # Moving the items before installation of new items
    #     sudo mv $folder "${configPath}backup/$folder.old" &>/dev/null
    #     # Else , items DO NOT Exist in .config path and we dont need to do something
    # fi
    exiItem "-d" "$folder" "`sudo mv $folder ${configPath}backup/$folder.old` &>/dev/null" ""
    done
}



function getResources {
    # Calling the function to verify if the folders already exists
    backupIfExist 
    # Getting the configuration files
    # Moving onto HOME user
    $switchHome
    createRes="cd $HOME && mkdir resources && cd resources/"
    exiItem -d "$HOME/resources/" "sudo mv resources/ ${configPath}backup/ && $createRes" "$createRes"
   # mkdir resources && cd resources
    pathResources=$HOME/resources
    # Cloning the confis from the following repo
    git clone https://github.com/IGerardoJR/dotfilesV3
    cd dotfilesV3/
    for element in ${dependencies[@]}
    do
        echo -e "$blueColor\Copying $element configuration files into the system $resetColor"
        mv $element $configPath/$element &>/dev/null
        sleep 1
    done
}

draggedAll=false

function warningMessage {
    echo -e "$yellowColor \WARNING: One or more dependencies didn't found, do you wish continue?(y/n) $resetColor"
    answer=""
    read answer
    if [[ $answer == "Y" || $answer == "y" || $answer == "yy" || $answer == "YY" || $answer == "yY" || $answer == "Yy" ]]
    then
        getResources
        sleep 1
        draggedAll=true
    else
        echo -e "$redColor\Nothing was installed $resetColor"
        sleep 1
        exit 0
    fi
}

if [[ $counterNotFound -gt 0 ]]
then
    warningMessage
elif [[ $draggedAll == false ]]
then
    echo -e "$greenColor\All dependencies was satisfied, getting the resources $resetColor"
    getResources
    sleep 1
fi


# Function to create .xinitrc
# function creatingInit {
#     exiItem -f "$HOME/.xinitrc"
#     addText=`echo "exec bspwm && sxhkd" >> .xinitrc`
#     if [[ $? == 0 ]]
#     then
#         $addText     
#     else
#         cd $HOME
#         touch .xinitrc
#         chmod +x .xinitrc
#         $addText
#     fi
# }

# creatingInit
# addText="`echo "exec bspwm && sxhkd" >> .xinitrc`"
# $switchHome
# exiItem -f ".xinitrc" $addText "cd $HOME && touch .xinitrc && chmod +xwr .xinitrc && $addText"

$switchHome
addText="`echo "exec bspwm && sxhkd" >> .xinitrc`"
exiItem "-f" ".xinitrc" "$addText" "`cd $HOME && touch .xinitrc && chmod +xwr .xinitrc && $addText`"


# -------------------------------------------------------------------------------------------------
# Getting the neccesary fonts

# fontsArray=("Iosevka","JetBrainsMono")

# function getFonts {
#     url=$1
#     nameFolder=$2
#     via=$3
#     cd $fontPath
#     for folder in ${fontsArray[@]}
#     do
#         exiItem -d $folder "pos" "neg"
#         # Making an smart backup
#         if [[ $? == 0 ]]
#         then
#         mv $folder $folder.old $dnull
#         fi
#     # Starting the download proccess
#     cd $fontPath
#     mkdir $2
#     cd $2
#     # Getting the fonts.zip via wget
#     if [[ $via == "wget" ]]
#     then
#     wget $url
#     else
#     git clone $3
#     fi
#     sleep 1
#     done
# }

# getFonts "https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/Iosevka.zip" "Iosevka" "wget"
# getFonts "https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/JetBrainsMono.zip" "JetBrainsMono" "wget"
# getFonts " https://github.com/daimoonis/material-icons-font" "material-icons-font" "github"



# Creating an default folder to target our downloaded images
cd $HOME 
# mkdir .draggedImage

#exiItem -d "$pathImages" ""
# The function above is gonna set an default image on bspwm to don't see a black screen for the first time.
function SetDefaultImages {

    # Installing Feh package to set an image
    installFeh="sudo apt-get install feh -y &>/dev/null"
    $installFeh

    cd $pathImages
    imageUrl=$1
    fileName=$2
    wget ${imageUrl}
    # Modifying the bspwmrc
    cd ${configPath}bspwm/
    echo `feh --bg-center $pathImages/$2 & >> bspwmrc $dnull`
}

#SetDefaultImages "https://lardy-aids.000webhostapp.com/198972.png" "198972.png"
SetDefaultImages "https://lardy-aids.000webhostapp.com/1228788.jpg" "1228788.jpg"
restart=""
echo -e "${greenColor}\Installation completed, you can restart your system now, do you want to restart?(y/n)${resetColor}"
sleep 2
read restart
if [[ restart == "y" || restart == "Y" ]]
then
    reboot
else
    exit 0
fi


