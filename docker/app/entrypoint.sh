#!/bin/sh
set -e

# wait for when the database is up and running
until psql postgres://$POSTGRES_USER:$POSTGRES_PASSWORD@$POSTGRES_HOST/$POSTGRES_DB -c '\l'; do
    >&2 echo "Postgres is unavailable - sleeping"
    sleep 1
done

>&2 echo "Postgres is up - continuing"

# migrate everything else
python manage.py migrate --noinput

# collect static files
python manage.py collectstatic --noinput

# restart (or start) the task scheduler

# start the webservice
gunicorn scraas.wsgi -b 0.0.0.0:8000

exec "$@"