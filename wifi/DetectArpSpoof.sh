#!/bin/env bash

packgeNeeded=("arping")

function installAllPackages(){
    read -p "Do you want to install missing Packages [y]: " answer
    if [[ $answer =~ [yY] ]];then sudo apt-get install -y ${packgeNeeded[@]} && exit ;else echo You must install all packges && exit ;fi
    
}


# echo help if no arguments were given 
if [ $# -eq 0 ]
then
    echo -e "run [range] [ InterfaceName ]\nExample 192.168.1 wlan0 "
    exit
fi

<< "subnet"

for SUBNET in {1..255}
do
for HOST in {1..255}
do
echo "[*] IP: "$PREFIX"."$SUBNET"."$HOST
arping –c 3 –i $INTERFACE $PREFIX"."$SUBNET"."$HOST 2>
/dev/null
done
done

subnet


PREFIX=$1
INTERFACE=$2


function finish() {
        echo -e "\nDone"
        exit 0
}

function detectArpSpoof(){
    for subnet in {1..255}
    do
        result=$(sudo arping -r -c 1 -d -i $INTERFACE $PREFIX.$subnet)
        #echo "what " $result
        if [ ! -z $result ]
        then
            NumberOfMac=$(echo $result | wc -l )
            if [[  ($NumberOfMac > 1) ]]
            then
                echo "Mac spoofing detected" echo -n "[*] Ip: $PREFIX.$subnet " $result
            else
                echo -n "[*] Ip: $PREFIX.$subnet " $result
                echo ""
            fi
        else
            echo -en " $subnet \r"
        fi
    done
}




dpkg -s ${packgeNeeded[@]} > /dev/null 2>&1 || installAllPackages 


trap finish SIGINT

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
else
    detectArpSpoof
fi


