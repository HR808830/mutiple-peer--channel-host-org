#!/bin/bash

if [ -z ${FABRIC_START_TIMEOUT+x} ]; then
 echo "FABRIC_START_TIMEOUT is unset, assuming 15 (seconds)"
 export FABRIC_START_TIMEOUT=15
else

   re='^[0-9]+$'
   if ! [[ $FABRIC_START_TIMEOUT =~ $re ]] ; then
      echo "FABRIC_START_TIMEOUT: Not a number" >&2; exit 1
   fi

 echo "FABRIC_START_TIMEOUT is set to '$FABRIC_START_TIMEOUT'"
fi

# Exit on first error, print all commands.
set -ev

#Detect architecture
ARCH=`uname -m`

# Grab the current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#

# ARCH=$ARCH docker-compose -f "${DIR}"/composer/docker-compose-peer2.yml down
ARCH=$ARCH docker-compose -f "${DIR}"/composer/docker-compose-peer2.yml up -d

# wait for Hyperledger Fabric to start
# incase of errors when running later commands, issue export FABRIC_START_TIMEOUT=<larger number>
echo ${FABRIC_START_TIMEOUT}
sleep ${FABRIC_START_TIMEOUT}

docker exec -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org2.iotblockchain.com/msp" peer0.org2.iotblockchain.com peer channel fetch config -o {IP-HOST-1}:7050 -c channeliot1
# docker exec -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org2.iotblockchain.com/msp" peer0.org2.iotblockchain.com peer channel fetch config -o orderer.iotblockchain.com:7050 -c channeliot1

docker exec -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org2.iotblockchain.com/msp" peer0.org2.iotblockchain.com peer channel join -b channeliot1_config.block

docker exec -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org2.iotblockchain.com/msp" peer1.org2.iotblockchain.com peer channel fetch config -o {IP-HOST-1}:7050 -c channeliot1
# docker exec -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org2.iotblockchain.com/msp" peer1.org2.iotblockchain.com peer channel fetch config -o orderer.iotblockchain.com:7050 -c channeliot1

docker exec -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org2.iotblockchain.com/msp" peer1.org2.iotblockchain.com peer channel join -b channeliot1_config.block

docker exec -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org2.iotblockchain.com/msp" peer2.org2.iotblockchain.com peer channel fetch config -o {IP-HOST-1}:7050 -c channeliot1
# docker exec -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org2.iotblockchain.com/msp" peer2.org2.iotblockchain.com peer channel fetch config -o orderer.iotblockchain.com:7050 -c channeliot1

docker exec -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org2.iotblockchain.com/msp" peer2.org2.iotblockchain.com peer channel join -b channeliot1_config.block



docker exec -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org2.iotblockchain.com/msp" peer0.org2.iotblockchain.com peer channel fetch config -o {IP-HOST-1}:7050 -c channeliot2
# docker exec -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org2.iotblockchain.com/msp" peer0.org2.iotblockchain.com peer channel fetch config -o orderer.iotblockchain.com:7050 -c channeliot2

docker exec -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org2.iotblockchain.com/msp" peer0.org2.iotblockchain.com peer channel join -b channeliot2_config.block

docker exec -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org2.iotblockchain.com/msp" peer1.org2.iotblockchain.com peer channel fetch config -o {IP-HOST-1}:7050 -c channeliot2
# docker exec -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org2.iotblockchain.com/msp" peer1.org2.iotblockchain.com peer channel fetch config -o orderer.iotblockchain.com:7050 -c channeliot2

docker exec -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org2.iotblockchain.com/msp" peer1.org2.iotblockchain.com peer channel join -b channeliot2_config.block

docker exec -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org2.iotblockchain.com/msp" peer2.org2.iotblockchain.com peer channel fetch config -o {IP-HOST-1}:7050 -c channeliot2
# docker exec -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org2.iotblockchain.com/msp" peer2.org2.iotblockchain.com peer channel fetch config -o orderer.iotblockchain.com:7050 -c channeliot2

docker exec -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org2.iotblockchain.com/msp" peer2.org2.iotblockchain.com peer channel join -b channeliot2_config.block

