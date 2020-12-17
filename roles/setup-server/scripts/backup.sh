#!/bin/bash -x
# gomatrixhosting-matrix-docker-ansible-deploy/docs/maintenance-postgres.md

cd /matrix || exit 1
STIME="$(date +%s)"

DUMPIT=1; TARIT=1;

if [ "$DUMPIT" = 1 ]; then
  rm -f /chroot/backup/postgres_*
  DATE=$(date '+%F')
  docker run \
  --rm \
  --log-driver=none \
  --network=matrix \
  --env-file=/matrix/postgres/env-postgres-psql \
  postgres:13.1-alpine \
  pg_dumpall -h matrix-postgres \
  | pigz --stdout --fast --blocksize 16384 --independent --processes 2 --rsyncable \
  > /chroot/backup/postgres_$DATE.sql.gz
fi

DOCKERRC="$?";
DOCKER_ETIME="$(date +%s)"
DOCKER_ELAPSED="$(($DOCKER_ETIME - $STIME))"

if [ "$TARIT" = 1 ]; then
  tar --exclude='./synapse/storage/media-store/remote_content' -czf /chroot/backup/matrix.tar.gz ./awx ./synapse
fi

TARRC="$?";
TAR_ETIME="$(date +%s)"
TAR_ELAPSED="$(($TAR_ETIME - $STIME))"

FILE_SIZE=$(stat -c '%s' /chroot/backup/postgres_$DATE.sql.gz)
DATE_TIME=$(date '+%F_%H:%M:%S')

chown -R sftp:sftp /chroot/backup/

echo "$DATE_TIME $0: Snapshot (returned $DOCKERRC at $DOCKER_ELAPSED seconds)+ TAR (returned $TARRC at $TAR_ELAPSED seconds) completed, database.gz size: $FILE_SIZE" >> /matrix/awx/backup.log


