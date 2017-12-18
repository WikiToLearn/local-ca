#!/bin/bash

export EASY_RSA_KEY_SIZE=2048 # 768
export EASY_RSA_CA_EXPIRE=365000
export EASY_RSA_KEY_EXPIRE=365000
export EASY_RSA_KEY_COUNTRY="MI"
export EASY_RSA_KEY_PROVINCE="MI"
export EASY_RSA_KEY_CITY="Milan"
export EASY_RSA_KEY_ORG="WikiToLearn"
export EASY_RSA_KEY_EMAIL="sysadmin@wikitolearn.org"
export EASY_RSA_KEY_OU="WikiToLearn CA"
export EASY_RSA_KEY_NAME="WikiToLearn EasyRSA"

rsync --delete -av /usr/share/easy-rsa/ easy-rsa
cd easy-rsa/

{
 echo 'export KEY_SIZE='$EASY_RSA_KEY_SIZE
 echo 'export CA_EXPIRE='$EASY_RSA_CA_EXPIRE
 echo 'export KEY_EXPIRE='$EASY_RSA_KEY_EXPIRE
 echo 'export KEY_COUNTRY="'$EASY_RSA_KEY_COUNTRY'"'
 echo 'export KEY_PROVINCE="'$EASY_RSA_KEY_PROVINCE'"'
 echo 'export KEY_CITY="'$EASY_RSA_KEY_CITY'"'
 echo 'export KEY_ORG="'$EASY_RSA_KEY_ORG'"'
 echo 'export KEY_EMAIL="'$EASY_RSA_KEY_EMAIL'"'
 echo 'export KEY_OU="'$EASY_RSA_KEY_OU'"'
 echo 'export KEY_NAME="'$EASY_RSA_KEY_NAME'"'
} >> vars

source ./vars
./clean-all
./build-ca --batch

export ADDALT_NAMES=""
for domain in "localhost"
do
 export ADDALT_NAMES=$ADDALT_NAMES",DNS:"$domain
 export ADDALT_NAMES=$ADDALT_NAMES",DNS:*."$domain
done

sed -i 's/subjectAltName=$ENV::KEY_ALTNAMES/subjectAltName=$ENV::KEY_ALTNAMES'$ADDALT_NAMES'/g' $KEY_CONFIG
./build-key-server --batch "www.wikitolearn.org"
sed -i 's/subjectAltName=$ENV::KEY_ALTNAMES.*/subjectAltName=$ENV::KEY_ALTNAMES/g' $KEY_CONFIG

export KEY_ALTNAMES=""
export KEY_CN=""
openssl ca -config $KEY_CONFIG -gencrl -keyfile keys/ca.key -cert keys/ca.crt -out keys/crl.pem
