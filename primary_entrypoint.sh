#!/usr/bin/env sh

set -e

## Create /var/lib/pgadmin/pgpass
# 1st database
POSTGRES_HOST_1=${POSTGRES_HOST_1:-$POSTGRES_HOST}
POSTGRES_PORT_1=${POSTGRES_PORT_1:-$POSTGRES_PORT}
POSTGRES_DB_1=${POSTGRES_DB_1:-$POSTGRES_DB}
POSTGRES_USER_1=${POSTGRES_USER_1:-$POSTGRES_USER}
POSTGRES_PASSWORD_1=${POSTGRES_PASSWORD_1:-$POSTGRES_PASSWORD}

echo "$POSTGRES_HOST_1:$POSTGRES_PORT_1:postgres:$POSTGRES_USER_1:$POSTGRES_PASSWORD_1" | tee -a "/var/lib/pgadmin/pgpass" >/dev/null
echo "$POSTGRES_HOST_1:$POSTGRES_PORT_1:$POSTGRES_DB_1:$POSTGRES_USER_1:$POSTGRES_PASSWORD_1" | tee -a "/var/lib/pgadmin/pgpass" >/dev/null

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
    _POSTGRES_HOST="$(eval echo \"\$POSTGRES_HOST_$COUNT\")"
    _POSTGRES_PORT="$(eval echo \"\$POSTGRES_PORT_$COUNT\")"

    # Set default for the postgres port
    if [ -z "$_POSTGRES_PORT" ]; then
        _POSTGRES_PORT="5432"
    fi

    # if POSTGRES_DB, default is "*"
    _POSTGRES_DB="$(eval echo \"\$POSTGRES_DB_$COUNT\")"
    if [ -z "$_POSTGRES_DB" ]; then
        _POSTGRES_DB="*"
    fi
    _POSTGRES_USER="$(eval echo \"\$POSTGRES_USER_$COUNT\")"
    _POSTGRES_PASSWORD="$(eval echo \"\$POSTGRES_PASSWORD_$COUNT\")"
    echo "$_POSTGRES_HOST:$_POSTGRES_PORT:postgres:$_POSTGRES_USER:$_POSTGRES_PASSWORD" | tee -a "/var/lib/pgadmin/pgpass_$COUNT" >/dev/null
    echo "$_POSTGRES_HOST:$_POSTGRES_PORT:$_POSTGRES_DB:$_POSTGRES_USER:$_POSTGRES_PASSWORD" | tee -a "/var/lib/pgadmin/pgpass_$COUNT" >/dev/null

    tee -a /pgadmin4/servers.json >/dev/null <<EOF
        ,"$COUNT": {
            "Name": "$_POSTGRES_HOST",
            "Group": "Servers",
            "Host": "$_POSTGRES_HOST",
            "Port": $_POSTGRES_PORT,
            "MaintenanceDB": "postgres",
            "Username": "$_POSTGRES_USER",
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

chmod 600 /var/lib/pgadmin/pgpass*
chown pgadmin:root /var/lib/pgadmin/pgpass*
chown pgadmin:root /pgadmin4/servers.json

exec /entrypoint.sh "$@"
