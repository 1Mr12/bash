#!/bin/bash

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

function MonitorMode {
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

stopMonitorMode() {
    echo seting MonitorMode off
    sudo airmon-ng stop $1 > /dev/null 2>&1
    #sudo ifconfig $1 down 
    #sudo iwconfig $1 mode Managed
    #sudo ifconfig $1 up
}


GetMacList() {
    interfacee=$(MonitorMode)
    echo $interfacee is on Monitor Mode
    sudo airodump-ng $1 -i $interfacee --output-format csv -w temp
    clear
    cat temp-01.csv | cut -d , -f 1 
    sudo rm -f temp*
}

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

