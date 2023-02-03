# Passwordless pgAdmin4 Container Image (dcagatay/pwless-pgadmin4)

pgAdmin4 container image with password-less usage configuration.

Image resides in DockerHub ([dcagatay/pwless-pgadmin4](https://hub.docker.com/r/dcagatay/pwless-pgadmin4)).

Sample usage can be found in the [_docker-compose.yml_](./docker-compose.yml) file.

## Environment variables

- `POSTGRES_USER`: Postgres DB user name. (**Required**)
- `POSTGRES_PASSWORD`: Postgres DB user password. (**Required**)
- `POSTGRES_HOST`: PostgreSQL DB Host. (Default: _postgres_)
- `POSTGRES_PORT`: PostgreSQL DB Port. (Default: _5432_)
- `POSTGRES_DB`: PostgreSQL DB name. (Default: _\*_, Asterisk means any db.)

You can add more hosts by adding the following environment variables, where X is the number of the host (starting from **2**):
- `POSTGRES_USER_X`: Postgres DB user name. (**Required**)
- `POSTGRES_PASSWORD_X`: Postgres DB user password. (**Required**)
- `POSTGRES_HOST_X`: PostgreSQL DB Host. (**Required**)
- `POSTGRES_PORT_X`: PostgreSQL DB Port. (**Required**)
- `POSTGRES_DB_X`: PostgreSQL DB name. (Default: _\*_, Asterisk means any db.)
