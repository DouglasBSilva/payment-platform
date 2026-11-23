#!/bin/bash

set -e

psql -v ON_ERROR_STOP=1 \
     --username "$POSTGRES_USER" \
     --dbname "$POSTGRES_DB" <<-EOSQL

    CREATE ROLE ledgers_migrator LOGIN PASSWORD '$POSTGRES_MIG_PASSWORD';
    CREATE ROLE ledgers_app LOGIN PASSWORD '$POSTGRES_APP_PASSWORD';
    
    ALTER DATABASE "$POSTGRES_DB" OWNER TO ledgers_migrator;
    GRANT CREATE ON SCHEMA public TO ledgers_migrator;
    GRANT USAGE ON SCHEMA public TO ledgers_app;

EOSQL