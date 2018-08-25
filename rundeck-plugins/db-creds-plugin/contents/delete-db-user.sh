#!/bin/bash -e

PGASSWORD=$2 psql -h database -U $1 -c "DROP USER $3" postgres
