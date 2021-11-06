#!/usr/bin/env bash

packgeNeeded=("arp-scan")

function installAllPackages(){
    read -p "Do you want to install missing Packages [y]: " answer
    if [[ $answer =~ [yY] ]];then sudo apt-get install -y ${packgeNeeded[@]} && exit ;else echo You must install all packges && exit ;fi
    
}


# echo help if no arguments were given 
if [ $# -eq 0 ]
then
    echo -e "run [ InterfaceName ]\nExample wlan0 "
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



function detectArpSpoof(){
    for subnet in {1..255}
    do
        result=$(sudo arping -r -c 1 -d -i $INTERFACE $PREFIX.$subnet)
        #echo "what " $result
        if [ ! -z $result ]
        then
            NumberOfMac=$(echo $result | wc -l )
            echo " $NumberOfMac For  $PREFIX.$subnet $result " 
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


subnet


PREFIX=$1
INTERFACE=$2


function finish() {
        echo -e "\nDone"
        exit 0
}


# pass $interfaceName
function detectMacSpoof(){
    listOfIpMac=$(sudo arp-scan -I $1 --localnet -q -x -r 1 )
    listOfIp=$(echo $listOfIpMac | cut -d " " -f 1 | sort)
    echo -e $listOfIp
    echo "remove \n"
    removeDuplication=$(echo $listOfIp | uniq )
    echo -e $removeDuplication
    
    #echo -e " $listOfIp\n \n $removeDuplication "
}




dpkg -s ${packgeNeeded[@]} > /dev/null 2>&1 || installAllPackages 


trap finish SIGINT

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
else
    detectMacSpoof $1
fi


