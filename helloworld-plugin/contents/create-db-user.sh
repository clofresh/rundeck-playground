#!/bin/bash -e

PGASSWORD=$2 psql -h rundeck-custom-plugin-example_database_1 -U $1 -c "CREATE USER $3 WITH ENCRYPTED PASSWORD '$4'" postgres
