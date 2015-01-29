#!/bin/bash -e

SRC=$1

rm -rf /tmp/keycloak-update

if [ -d "$SRC" ]; then
    if [ -d "$SRC/keycloak" ]; then
        SRC="$SRC/keycloak"
    fi
elif [ -f "$SRC" ]; then
    mkdir /tmp/keycloak-update
    unzip "$SRC" -d /tmp/keycloak-update
    SRC=$(ls -d /tmp/keycloak-update/keycloak-appliance-dist-all-*/keycloak)
else
    echo "usage: update.sh <src dir|zip>"
fi

if [ ! -f "$SRC/standalone/configuration/keycloak-server.json" ]; then
    echo "invalid dir"
    exit 1
fi

VERSION=$(ls $SRC/standalone/deployments/auth-server.war/WEB-INF/lib/keycloak-core-*.jar | head -n 1 | sed 's/^.*keycloak-core-//' | sed 's/.jar$//')

rm -rf versions/8/modules/system/layers/base
rm -rf versions/8/standalone/configuration/themes
rm -rf versions/8/standalone/deployments/auth*

cp -r $SRC/modules/system/layers/base versions/8/modules/system/layers/
cp -r $SRC/standalone/configuration/themes versions/8/standalone/configuration/
cp -r $SRC/standalone/deployments/auth* versions/8/standalone/deployments/

sed -i 's|<!--||g' versions/8/standalone/deployments/auth-server.war/WEB-INF/web.xml
sed -i 's|-->||g' versions/8/standalone/deployments/auth-server.war/WEB-INF/web.xml

sed -i "s/Display-Name: Keycloak .*/Display-Name: Keycloak $VERSION/" metadata/manifest.yml
