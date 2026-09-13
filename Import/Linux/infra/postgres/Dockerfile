FROM postgres:16

COPY init/dump.pgc       /docker-entrypoint-initdb.d/dump.pgc
COPY init/01-restore.sh  /docker-entrypoint-initdb.d/01-restore.sh

RUN chmod +x /docker-entrypoint-initdb.d/01-restore.sh
