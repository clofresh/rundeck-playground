#!/bin/bash -e

PGASSWORD=$2 psql -h database -U $1 -c "CREATE USER $3 WITH ENCRYPTED PASSWORD '$4'; GRANT $5 to $3;" postgres
