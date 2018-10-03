#!/bin/bash

set -e

mkdir -p /var/odk/ /workdir/root /workdir/settings
WAR=ODKAggregate_1.6.1.war
SETTINGS=${CATALINA_HOME}/webapps/ROOT/WEB-INF/lib/ODKAggregate-settings.jar

function configure() {

    # the following will create a schema called odk, so that ODK can run its sql
    /opt/flyway/flyway \
            -url=$DATABASE_URL \
            -schemas=odk \
            -user=$POSTGRES_USER \
            -password=$POSTGRES_PASSWORD \
            -table=odk_init_migration \
            migrate

    pushd /workdir/root
    jar -xvf $CATALINA_HOME/webapps/ROOT.war
    pushd /workdir/settings
    jar -xvf /workdir/root/WEB-INF/lib/ODKAggregate-settings.jar

    echo "---- Modifying ODK Aggregate security.properties ----"

    echo "Updating security.server.hostname"
    sed -i -E "s|^(security.server.hostname=).*|\1$ODK_HOSTNAME|gm" security.properties

    echo "Updating security.server.superUserUsername"
    sed -i -E "s|^(security.server.superUserUsername=).*|\1$ODK_ADMIN_USERNAME|gm" security.properties

    echo "Updating security.server.realm.realmString"
    sed -i -E "s|^(security.server.realm.realmString=).*|\1$ODK_AUTH_REALM|gm" security.properties

    cp security.properties ~/

    echo "---- Modifying ODK Aggregate jdbc.properties ----"
    sed -i -E "s|^(jdbc.url=).+(\?autoDeserialize=true)|\1$DATABASE_URL\2|gm" jdbc.properties
    sed -i -E "s|^(jdbc.schema=).*|\1odk|gm" jdbc.properties
    sed -i -E "s|^(jdbc.username=).*|\1$POSTGRES_USER|gm" jdbc.properties
    sed -i -E "s|^(jdbc.password=).*|\1$POSTGRES_PASSWORD|gm" jdbc.properties
    cp jdbc.properties ~/

    echo "---- Rebuilding ODKAggregate-settings.jar ----"
    jar cvf /workdir/ODKAggregate-settings.jar ./*
    popd

    mv -f /workdir/ODKAggregate-settings.jar /workdir/root/WEB-INF/lib/ODKAggregate-settings.jar
    echo "---- Rebuilding ${WAR} ----"
    jar cvf $CATALINA_HOME/webapps/ROOT.war ./*
    popd

    echo "---- Deploying ${WAR} to $CATALINA_HOME/webapps/ROOT.war ----"
    rm -rf $CATALINA_HOME/webapps/ROOT

    touch /var/odk/.inititlized

    echo "---- Init DB schema ---"

  echo "---- Tomcat & ODK Aggregate Setup Complete ---"
}


if [ -z "$1" ];then
    echo "entrypoint.sh [setup|odk] or command"
fi

if [ "$1" = "setup" ]; then
    configure
elif [ "$1" = "odk" ]; then
    if [ ! -f /var/odk/.inititlized ]; then
        configure
    fi
    exec $CATALINA_HOME/bin/catalina.sh run "$@"
else
    exec $@
fi

