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

ARCH=$ARCH docker-compose -f "${DIR}"/composer/docker-compose.yml down
ARCH=$ARCH docker-compose -f "${DIR}"/composer/docker-compose.yml up -d

# wait for Hyperledger Fabric to start
# incase of errors when running later commands, issue export FABRIC_START_TIMEOUT=<larger number>
echo ${FABRIC_START_TIMEOUT}
sleep ${FABRIC_START_TIMEOUT}

# Create the channel
docker exec peer0.org1.iotblockchain.com peer channel create -o orderer.iotblockchain.com:7050 -c channeliot1 -f /etc/hyperledger/configtx/channeliot1.tx

# Join peer0.org1.iotblockchain.com to the channel.
docker exec -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.iotblockchain.com/msp" peer0.org1.iotblockchain.com peer channel join -b channeliot1.block


# # Create the channel
docker exec -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.iotblockchain.com/msp" peer1.org1.iotblockchain.com peer channel fetch config -o orderer.iotblockchain.com:7050 -c channeliot1
# docker exec peer1.org1.iotblockchain.com peer channel create -o orderer.iotblockchain.com:7050 -c channeliot1 -f /etc/hyperledger/configtx/channeliot1.tx

# # Join peer1.org1.iotblockchain.com to the channel.
docker exec -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.iotblockchain.com/msp" peer1.org1.iotblockchain.com peer channel join -b channeliot1_config.block

# # Create the channel
docker exec -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.iotblockchain.com/msp" peer2.org1.iotblockchain.com peer channel fetch config -o orderer.iotblockchain.com:7050 -c channeliot1
# docker exec peer1.org1.iotblockchain.com peer channel create -o orderer.iotblockchain.com:7050 -c channeliot1 -f /etc/hyperledger/configtx/channeliot1.tx

# # Join peer1.org1.iotblockchain.com to the channel.
docker exec -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.iotblockchain.com/msp" peer2.org1.iotblockchain.com peer channel join -b channeliot1_config.block






# Create the channel channeliot2
docker exec peer0.org1.iotblockchain.com peer channel create -o orderer.iotblockchain.com:7050 -c channeliot2 -f /etc/hyperledger/configtx/channeliot2.tx

# Join peer0.org1.iotblockchain.com to the channel channeliot2.
docker exec -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.iotblockchain.com/msp" peer0.org1.iotblockchain.com peer channel join -b channeliot2.block


# # Create the channel channeliot2
docker exec -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.iotblockchain.com/msp" peer1.org1.iotblockchain.com peer channel fetch config -o orderer.iotblockchain.com:7050 -c channeliot2
# docker exec peer1.org1.iotblockchain.com peer channel create -o orderer.iotblockchain.com:7050 -c channeliot2 -f /etc/hyperledger/configtx/channeliot2.tx

# # Join peer1.org1.iotblockchain.com to the channel channeliot2.
docker exec -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.iotblockchain.com/msp" peer1.org1.iotblockchain.com peer channel join -b channeliot2_config.block

# # Create the channel channeliot2
docker exec -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.iotblockchain.com/msp" peer2.org1.iotblockchain.com peer channel fetch config -o orderer.iotblockchain.com:7050 -c channeliot2
# docker exec peer1.org1.iotblockchain.com peer channel create -o orderer.iotblockchain.com:7050 -c channeliot2 -f /etc/hyperledger/configtx/channeliot2.tx

# # Join peer1.org1.iotblockchain.com to the channel channeliot2.
docker exec -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.iotblockchain.com/msp" peer2.org1.iotblockchain.com peer channel join -b channeliot2_config.block


