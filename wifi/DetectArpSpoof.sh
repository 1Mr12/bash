#!/bin/env bash

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
        if [ ! -z $result ]
        then
            echo -n "[*] Ip: $PREFIX.$subnet " $result
            echo ""
        else
            echo -en " $subnet \r"
        fi
    done
}






trap finish SIGINT

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
else
    detectArpSpoof
fi


