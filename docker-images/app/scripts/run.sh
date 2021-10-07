#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

postgres_ready() {
python << END
import sys
import psycopg2

try:
    psycopg2.connect(
        dbname="${APP_DB_NAME}",
        user="${APP_DB_USER}",
        password="${APP_DB_PASSWORD}",
        host="${APP_DB_HOST}",
        port="${APP_DB_PORT}",
    )
except psycopg2.OperationalError:
    sys.exit(-1)
sys.exit(0)
END
}
until postgres_ready; do
>&2 echo 'Waiting for PostgreSQL to become available...'
sleep 1
done
>&2 echo 'PostgreSQL is available'

if [[ ${ENV} == "dev" ]];then

  exec python manage.py runserver 0.0.0.0:8000

elif [[ ${ENV} == "prod" ]];then

  exec gunicorn -c /app/gunicorn_conf.py app.wsgi:application

else

  echo "No authorized env found, exiting..."

  exit 127

fi
