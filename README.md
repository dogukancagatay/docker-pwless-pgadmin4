# Passwordless pgAdmin4 Container Image (dcagatay/pwless-pgadmin4)

pgAdmin4 container image with password-less usage configuration.

Image resides in DockerHub ([dcagatay/pwless-pgadmin4](https://hub.docker.com/r/dcagatay/pwless-pgadmin4)).

Sample usage can be found in the [_docker-compose.yml_](https://github.com/dogukancagatay/docker-pwless-pgadmin4/blob/master/docker-compose.yml) file.

## Environment variables

- `POSTGRES_USER`: Postgres DB user name. (**Required**)
- `POSTGRES_PASSWORD`: Postgres DB user password. (**Required**)
- `POSTGRES_HOST`: PostgreSQL DB Host. (Default: _postgres_)
- `POSTGRES_PORT`: PostgreSQL DB Port. (Default: _5432_)
- `POSTGRES_DB`: PostgreSQL DB name. (Default: _\*_, Asterisk means any db.)

## Caveats

- Currently supports only one host and one database (can give \*\*" for multiple databases with the same credentials).
