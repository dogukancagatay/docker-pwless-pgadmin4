#!/usr/bin/env sh

# set -x
set -e

## Create /var/lib/pgadmin/pgpass
# 1st database
echo "$POSTGRES_HOST:$POSTGRES_PORT:$POSTGRES_DB:$POSTGRES_USER:$POSTGRES_PASSWORD" | tee "/var/lib/pgadmin/pgpass" >/dev/null
POSTGRES_HOST_1=$POSTGRES_HOST
POSTGRES_PORT_1=$POSTGRES_PORT
POSTGRES_DB_1=$POSTGRES_DB
POSTGRES_USER_1=$POSTGRES_USER
POSTGRES_PASSWORD_1=$POSTGRES_PASSWORD

## Create servers.json
tee /pgadmin4/servers.json >/dev/null <<EOF
{
    "Servers": {
        "1": {
            "Name": "$POSTGRES_HOST_1",
            "Group": "Servers",
            "Host": "$POSTGRES_HOST_1",
            "Port": $POSTGRES_PORT_1,
            "MaintenanceDB": "postgres",
            "Username": "$POSTGRES_USER_1",
            "SSLMode": "prefer",
            "PassFile": "/var/lib/pgadmin/pgpass"
        }
EOF

# if there are more than 1 database then
# loop through environment variables and create password files
COUNT=2
while [ ! -z "$(eval echo \"\$POSTGRES_HOST_$COUNT\")" ]; do
    POSTGRES_HOST="$(eval echo \"\$POSTGRES_HOST_$COUNT\")"
    POSTGRES_PORT="$(eval echo \"\$POSTGRES_PORT_$COUNT\")"
    # if POSTGRES_DB, default is "*"
    POSTGRES_DB="$(eval echo \"\$POSTGRES_DB_$COUNT\")"
    if [ -z "$POSTGRES_DB" ]; then
        POSTGRES_DB="*"
    fi
    POSTGRES_USER="$(eval echo \"\$POSTGRES_USER_$COUNT\")"
    POSTGRES_PASSWORD="$(eval echo \"\$POSTGRES_PASSWORD_$COUNT\")"
    echo "$POSTGRES_HOST:$POSTGRES_PORT:$POSTGRES_DB:$POSTGRES_USER:$POSTGRES_PASSWORD" | tee "/var/lib/pgadmin/pgpass_$COUNT" >/dev/null

    tee -a /pgadmin4/servers.json >/dev/null <<EOF
        ,"$COUNT": {
            "Name": "$POSTGRES_HOST",
            "Group": "Servers",
            "Host": "$POSTGRES_HOST",
            "Port": $POSTGRES_PORT,
            "MaintenanceDB": "postgres",
            "Username": "$POSTGRES_USER",
            "SSLMode": "prefer",
            "PassFile": "/var/lib/pgadmin/pgpass_$COUNT"
        }
EOF

    COUNT=$((COUNT + 1))
done

# close servers.json
tee -a /pgadmin4/servers.json >/dev/null <<EOF
    }
}
EOF

chmod 600 `ls /var/lib/pgadmin/pgpass*`
chown pgadmin:root `ls /var/lib/pgadmin/pgpass*`
chown pgadmin:root /pgadmin4/servers.json

exec /entrypoint.sh "$@"
