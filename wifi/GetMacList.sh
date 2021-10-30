#!/bin/env bash

packgeNeeded=("aircrack-ng" "iw" "wireless-tools" )


if [ $# -eq 0 ]
then
    echo -e "-e for wifi essid\n-b for wifi bssid"
fi

# Get arguments 
while getopts "b:e:r" option;
do
    case $option in
        e) # set wiff essid
            wifiEssid=$OPTARG;;
        b)
            wifiBssid=$OPTARG;;
        r)
            rest=True;;
        \?) # unexpected arguments 
            echo -e "\n-e for wifi essid\n-b for wifi bssid "
            exit;;


    esac
done


#dpkg -s $1 &> /dev/null [ $? -eq 0 ] > installed 1 > not installed
function installAllPackages(){
    read -p "Do you want to install missing Packages [y]: " answer
    if [[ $answer =~ [yY] ]];then sudo apt-get install -y ${packgeNeeded[@]}  ;else echo You must install all packges && exit ;fi
    
}



function startMonitorMode {
    interface=$(iw dev | grep Interface |cut -d " " -f2)
    interfaceMode=$(iwconfig $interface |grep -o Monitor)
    
    if [ ! -z $interfaceMode ]
    then
        echo "$interface"
    else
        sudo airmon-ng start $interface > /dev/null 2>&1
        interface=$(iw dev | grep Interface |cut -d " " -f2)
        echo "$interface"
        
    fi

}

function stopMonitorMode() {
    sudo airmon-ng stop $1 > /dev/null 2>&1
    echo seting MonitorMode off
    interface=$(iw dev | grep Interface |cut -d " " -f2)
    interfaceMode=$(iwconfig $interface |grep -o Monitor)
    if [ ! -z $interfaceMode ]
    then
        sudo ifconfig $interface down 
        sudo iwconfig $interface mode Managed
        sudo ifconfig $interface up
    else
        echo "Monitor mode is off"
    fi
    
}


function GetMacList() {
    interfacee=$(startMonitorMode)
    echo $interfacee is on Monitor Mode
    sudo airodump-ng $1 -i $interfacee --output-format csv -w temp
    clear
    cat temp-01.csv | cut -d , -f 1 
    sudo rm -f temp*
}

dpkg -s ${packgeNeeded[@]} > /dev/null 2>&1 || installAllPackages 

if [ ! -z $wifiBssid ]
then
    GetMacList "-d $wifiBssid"
    if [ $rest ]
    then
        stopMonitorMode $interfacee
    fi
    exit
elif [ ! -z $wifiEssid ]
then
    GetMacList "--essid $wifiEssid"
    if [ $rest ]
    then
        stopMonitorMode $interfacee
    fi
    exit
else
    echo "You Must Give Essid or bssid "
fi

