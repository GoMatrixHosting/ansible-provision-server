#!/bin/bash -x
# gomatrixhosting-matrix-docker-ansible-deploy/docs/maintenance-postgres.md

cd /chroot/backup/snapshot || exit 1
STIME="$(date +%s)"

DUMPIT=1; BORGIT=1;

if [ "$DUMPIT" = 1 ]; then
  rm -f ./postgres-latest.sql.gzip.gz

  docker run \
  --rm \
  --log-driver=none \
  --network=matrix \
  --env-file=/matrix/postgres/env-postgres-psql \
  postgres:13.1-alpine \
  pg_dumpall -h matrix-postgres \
  | pigz --stdout --fast --blocksize 16384 --independent --processes 2 --rsyncable \
  > ./postgres-latest.sql.gzip.gz
fi

DOCKERRC="$?";
DOCKER_ETIME="$(date +%s)"
DOCKER_ELAPSED="$(($DOCKER_ETIME - $STIME))"

if [ "$BORGIT" = 1 ]; then
  ionice -c3 borgmatic
fi
BORGMATICRC="$?";
BORGMATIC_ETIME="$(date +%s)"
BORGMATIC_ELAPSED="$(($BORGMATIC_ETIME - $STIME))"

FILE_SIZE=$(stat -c '%s' /chroot/backup/snapshot/postgres-latest.sql.gzip.gz)
DATE_TIME=$(date '+%F_%H:%M:%S')

cp -a -r /root/.config/borg /chroot/backup/root/.config/
cp -a -r /root/.cache/borg /chroot/backup/root/.cache/
chown -R sftp:sftp /chroot/backup/

echo "$DATE_TIME $0: Snapshot (returned $DOCKERRC at $DOCKER_ELAPSED seconds)+ BorgBackup (returned $BORGMATICRC at $BORGMATIC_ELAPSED seconds) completed, database.gz size: $FILE_SIZE" >> /matrix/awx/backup.log
