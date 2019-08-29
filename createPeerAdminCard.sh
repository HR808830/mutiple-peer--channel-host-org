#!/bin/bash

# Exit on first error
set -e
# Grab the current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Grab the file names of the keystore keys
ORG1KEY="$(ls composer/crypto-config/peerOrganizations/org1.iotblockchain.com/users/Admin@org1.iotblockchain.com/msp/keystore/)"
ORG2KEY="$(ls composer/crypto-config/peerOrganizations/org2.iotblockchain.com/users/Admin@org2.iotblockchain.com/msp/keystore/)"

echo
# check that the composer command exists at a version >v0.14
if hash composer 2>/dev/null; then
    composer --version | awk -F. '{if ($2<15) exit 1}'
    if [ $? -eq 1 ]; then
        echo 'Sorry, Use createConnectionProfile for versions before v0.15.0' 
        exit 1
    else
        echo Using composer-cli at $(composer --version)
    fi
else
    echo 'Need to have composer-cli installed at v0.15 or greater'
    exit 1
fi
# need to get the certificate

cat << EOF > org1onlyconnection.json
{
    "name": "iot-network-org1-only",
    "type": "hlfv1",
    "orderers": [
        {
            "url" : "grpc://localhost:7050",
            "hostnameOverride" : "orderer.iotblockchain.com"
        }
    ],
    "ca": {
        "url": "http://localhost:7054",
        "name": "ca.org1.iotblockchain.com",
        "hostnameOverride": "ca.org1.iotblockchain.com"
    },
    "peers": [
        {
            "requestURL": "grpc://localhost:7051",
            "eventURL": "grpc://localhost:7053",
            "hostnameOverride": "peer0.org1.iotblockchain.com"
        }, {
            "requestURL": "grpc://localhost:8051",
            "eventURL": "grpc://localhost:8053",
            "hostnameOverride": "peer1.org1.iotblockchain.com"
        }, {
            "requestURL": "grpc://localhost:9051",
            "eventURL": "grpc://localhost:9053",
            "hostnameOverride": "peer2.org1.iotblockchain.com"
        }
    ],
    "channel": "composerchannel",
    "channels": {
        "channeliot1": {
            "orderers": [
                "orderer.iotblockchain.com"
            ],
            "peers": {
                "peer0.org1.iotblockchain.com": {},
                "peer1.org1.iotblockchain.com": {},
                "peer2.org1.iotblockchain.com": {},
                "peer3.org1.iotblockchain.com": {},
                "peer4.org1.iotblockchain.com": {},
                "peer5.org1.iotblockchain.com": {}
            }
        },
        "channeliot2": {
            "orderers": [
                "orderer.iotblockchain.com"
            ],
            "peers": {
                "peer0.org1.iotblockchain.com": {},
                "peer1.org1.iotblockchain.com": {},
                "peer2.org1.iotblockchain.com": {},
                "peer3.org1.iotblockchain.com": {},
                "peer4.org1.iotblockchain.com": {},
                "peer5.org1.iotblockchain.com": {}
            }
        }
    },
    "mspID": "Org1MSP",
    "timeout": 300
}
EOF

cat << EOF > org1connection.json
{
    "name": "iot-network-org1",
    "type": "hlfv1",
    "orderers": [
        {
            "url" : "grpc://localhost:7050",
            "hostnameOverride" : "orderer.iotblockchain.com"
        }
    ],
    "ca": {
        "url": "http://localhost:7054",
        "name": "ca.org1.iotblockchain.com",
        "hostnameOverride": "ca.org1.iotblockchain.com"
    },
    "peers": [
        {
            "requestURL": "grpc://localhost:7051",
            "eventURL": "grpc://localhost:7053",
            "hostnameOverride": "peer0.org1.iotblockchain.com"
        }, {
            "requestURL": "grpc://localhost:8051",
            "eventURL": "grpc://localhost:8053",
            "hostnameOverride": "peer1.org1.iotblockchain.com"
        }, {
            "requestURL": "grpc://localhost:9051",
            "eventURL": "grpc://localhost:9053",
            "hostnameOverride": "peer2.org1.iotblockchain.com"
        }, {
            "requestURL": "grpc://{IP-HOST-2}:10051",
            "hostnameOverride": "peer0.org2.iotblockchain.com"
        }, {
            "requestURL": "grpc://{IP-HOST-2}:11051",
            "hostnameOverride": "peer1.org2.iotblockchain.com"
        }, {
            "requestURL": "grpc://{IP-HOST-2}:12051",
            "hostnameOverride": "peer2.org2.iotblockchain.com"
        }
    ],
    "channel": "composerchannel",
    "mspID": "Org1MSP",
    "timeout": 300
}
EOF

PRIVATE_KEY="${DIR}"/composer/crypto-config/peerOrganizations/org1.iotblockchain.com/users/Admin@org1.iotblockchain.com/msp/keystore/"${ORG1KEY}"
CERT="${DIR}"/composer/crypto-config/peerOrganizations/org1.iotblockchain.com/users/Admin@org1.iotblockchain.com/msp/signcerts/Admin@org1.iotblockchain.com-cert.pem

if composer card list -n @iot-network-org1-only > /dev/null; then
    composer card delete -n @iot-network-org1-only
fi

if composer card list -n @iot-network-org1 > /dev/null; then
    composer card delete -n @iot-network-org1
fi

composer card create -p org1onlyconnection.json -u PeerAdmin -c "${CERT}" -k "${PRIVATE_KEY}" -r PeerAdmin -r ChannelAdmin --file /tmp/PeerAdmin@iot-network-org1-only.card
composer card import --file /tmp/PeerAdmin@iot-network-org1-only.card

composer card create -p org1connection.json -u PeerAdmin -c "${CERT}" -k "${PRIVATE_KEY}" -r PeerAdmin -r ChannelAdmin --file /tmp/PeerAdmin@iot-network-org1.card
composer card import --file /tmp/PeerAdmin@iot-network-org1.card

rm -rf org1onlyconnection.json

cat << EOF > org2onlyconnection.json
{
    "name": "iot-network-org2-only",
    "type": "hlfv1",
    "orderers": [
        {
            "url" : "grpc://localhost:7050",
            "hostnameOverride": "orderer.iotblockchain.com"
        }
    ],
    "ca": {
        "url": "http://{IP-HOST-2}:7054",
        "name": "ca.org2.iotblockchain.com",
        "hostnameOverride": "ca.org2.iotblockchain.com"
    },
    "peers": [
        {
            "requestURL": "grpc://{IP-HOST-2}:10051",
            "eventURL": "grpc://{IP-HOST-2}:10053",
            "hostnameOverride": "peer0.org2.iotblockchain.com"
        }, {
            "requestURL": "grpc://{IP-HOST-2}:11051",
            "eventURL": "grpc://{IP-HOST-2}:11053",
            "hostnameOverride": "peer1.org2.iotblockchain.com"

        }, {
            "requestURL": "grpc://{IP-HOST-2}:12051",
            "eventURL": "grpc://{IP-HOST-2}:12053",
            "hostnameOverride": "peer2.org2.iotblockchain.com"
        }
    ],
    "channel": "composerchannel",
    "mspID": "Org2MSP",
    "timeout": 300
}
EOF

cat << EOF > org2connection.json
{
    "name": "iot-network-org2",
    "type": "hlfv1",
    "orderers": [
        {
            "url" : "grpc://localhost:7050",
            "hostnameOverride": "orderer.iotblockchain.com"
        }
    ],
    "ca": {
        "url": "http://{IP-HOST-2}:7054",
        "name": "ca.org2.iotblockchain.com",
        "hostnameOverride": "ca.org2.iotblockchain.com"
    },
    "peers": [
        {
            "requestURL": "grpc://localhost:7051",
            "hostnameOverride": "peer0.org1.iotblockchain.com"
        }, {
            "requestURL": "grpc://localhost:8051",
            "hostnameOverride": "peer1.org1.iotblockchain.com"
        }, {
            "requestURL": "grpc://localhost:9051",
            "hostnameOverride": "peer2.org1.iotblockchain.com"
        }, {
            "requestURL": "grpc://{IP-HOST-2}:10051",
            "eventURL": "grpc://{IP-HOST-2}:10053",
            "hostnameOverride": "peer0.org2.iotblockchain.com"
        }, {
            "requestURL": "grpc://{IP-HOST-2}:11051",
            "eventURL": "grpc://{IP-HOST-2}:11053",
            "hostnameOverride": "peer1.org2.iotblockchain.com"
        }, {
            "requestURL": "grpc://{IP-HOST-2}:12051",
            "eventURL": "grpc://{IP-HOST-2}:12053",
            "hostnameOverride": "peer2.org2.iotblockchain.com"
        }
    ],
    "channel": "composerchannel",
    "mspID": "Org2MSP",
    "timeout": 300
}
EOF

PRIVATE_KEY="${DIR}"/composer/crypto-config/peerOrganizations/org2.iotblockchain.com/users/Admin@org2.iotblockchain.com/msp/keystore/"${ORG2KEY}"
CERT="${DIR}"/composer/crypto-config/peerOrganizations/org2.iotblockchain.com/users/Admin@org2.iotblockchain.com/msp/signcerts/Admin@org2.iotblockchain.com-cert.pem


if composer card list -n @iot-network-org2-only > /dev/null; then
    composer card delete -n @iot-network-org2-only
fi

if composer card list -n @iot-network-org2 > /dev/null; then
    composer card delete -n @iot-network-org2
fi

composer card create -p org2onlyconnection.json -u PeerAdmin -c "${CERT}" -k "${PRIVATE_KEY}" -r PeerAdmin -r ChannelAdmin --file /tmp/PeerAdmin@iot-network-org2-only.card
composer card import --file /tmp/PeerAdmin@iot-network-org2-only.card

composer card create -p org2connection.json -u PeerAdmin -c "${CERT}" -k "${PRIVATE_KEY}" -r PeerAdmin -r ChannelAdmin --file /tmp/PeerAdmin@iot-network-org2.card
composer card import --file /tmp/PeerAdmin@iot-network-org2.card

rm -rf org2onlyconnection.json

echo "Hyperledger Composer PeerAdmin card has been imported"
composer card list

composer runtime install -c PeerAdmin@iot-network-org1-only -n iot-network
composer runtime install -c PeerAdmin@iot-network-org2-only -n iot-network
composer identity request -c PeerAdmin@iot-network-org1-only -u admin -s adminpw -d iotnode1
composer identity request -c PeerAdmin@iot-network-org2-only -u admin -s adminpw -d iotnode2
composer network start -c PeerAdmin@iot-network-org1 -a iot-network.bna -o endorsementPolicyFile=endorsement-policy.json -A iotnode1 -C iotnode1/admin-pub.pem -A iotnode2 -C iotnode2/admin-pub.pem
composer card create -p org1connection.json -u iotnode1 -n iot-network -c iotnode1/admin-pub.pem -k iotnode1/admin-priv.pem
composer card import -f iotnode1@iot-network.card
composer card create -p org2connection.json -u iotnode2 -n iot-network -c iotnode2/admin-pub.pem -k iotnode2/admin-priv.pem
composer card import -f iotnode2@iot-network.card
