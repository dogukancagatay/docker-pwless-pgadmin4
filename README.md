# Passwordless pgAdmin4 Container Image (dcagatay/pwless-pgadmin4)

pgAdmin4 container image with password-less usage configuration.

Sample `docker-compose.yml` usage:

```yaml
  pgadmin4:
    image: dcagatay/pwless-pgadmin4:latest
    ports:
      - 15432:80
    environment:
      POSTGRES_USER: my_user
      POSTGRES_PASSWORD: my_pass
      # POSTGRES_HOST: "postgres"
      # POSTGRES_PORT: "5432"
      # POSTGRES_DB: "*"
```

A quick example could be found in [`docker-compose.yml`](https://github.com/dogukancagatay/docker-pwless-pgadmin4/blob/master/docker-compose.yml).

## Environment variables

- `POSTGRES_USER`: Postgres DB user name. (**Required**)
- `POSTGRES_PASSWORD`: Postgres DB user password. (**Required**)
- `POSTGRES_HOST`: PostgreSQL DB Host. (Default: _postgres_)
- `POSTGRES_PORT`: PostgreSQL DB Port. (Default: _5432_)
- `POSTGRES_DB`: PostgreSQL DB name. (Default: _\*_, Asterisk means any db.)

### Multi Server Config

You can add more hosts by adding enumerated environment variables, where X is the number of the host (starting from **2**):

- `POSTGRES_USER_X`: Postgres DB user name. (**Required**)
- `POSTGRES_PASSWORD_X`: Postgres DB user password. (**Required**)
- `POSTGRES_HOST_X`: PostgreSQL DB Host. (**Required**)
- `POSTGRES_PORT_X`: PostgreSQL DB Port. (Default: _5432_)
- `POSTGRES_DB_X`: PostgreSQL DB name. (Default: _\*_, Asterisk means any db.)

An multi database example usage could be found in [`docker-compose-multi.yml`](https://github.com/dogukancagatay/docker-pwless-pgadmin4/blob/master/docker-compose-multi.yml).

## Links

- Source code is @Github [dogukancagatay/docker-pwless-pgadmin4](https://github.com/dogukancagatay/docker-pwless-pgadmin4).
- Container image resides @DockerHub [dcagatay/pwless-pgadmin4](https://hub.docker.com/r/dcagatay/pwless-pgadmin4).
