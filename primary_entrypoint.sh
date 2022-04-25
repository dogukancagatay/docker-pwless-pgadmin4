#!/usr/bin/env sh

# set -x
set -e

## Create /var/lib/pgadmin/pgpass
echo "$POSTGRES_HOST:$POSTGRES_PORT:$POSTGRES_DB:$POSTGRES_USER:$POSTGRES_PASSWORD" | tee /var/lib/pgadmin/pgpass >/dev/null

chmod 600 /var/lib/pgadmin/pgpass
chown pgadmin:root /var/lib/pgadmin/pgpass

## Create servers.json
tee /pgadmin4/servers.json >/dev/null <<EOF
{
    "Servers": {
        "1": {
            "Name": "$POSTGRES_HOST",
            "Group": "Servers",
            "Host": "$POSTGRES_HOST",
            "Port": $POSTGRES_PORT,
            "MaintenanceDB": "postgres",
            "Username": "$POSTGRES_USER",
            "SSLMode": "prefer",
            "PassFile": "/var/lib/pgadmin/pgpass"
        }
    }
}
EOF
chown pgadmin:root /pgadmin4/servers.json

exec /entrypoint.sh "$@"
