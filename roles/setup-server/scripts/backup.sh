#!/bin/bash -x
# chatoasis-matrix-docker-ansible-deploy/docs/maintenance-postgres.md

cd /backup/snapshot-latest || exit 1
STIME="$(date +%s)"

DUMPIT=1; BORGIT=1;

#single block:		| gzip -c --fast --rsyncable \
#vs: 16MB blocks:	| pigz --stdout --fast --blocksize 16384 --independent --processes 2 --rsyncable \
# borgbackup has ~2MiB default chunks: https://borgbackup.readthedocs.io/en/stable/internals/data-structures.html#chunker-details
#  | pv --rate-limit=2000K --interval 600 \
if [ "$DUMPIT" = 1 ]; then
  FNEW=./postgres.sql.gzip-1--rsyncable.latest.gz
  FOLD=../snapshot-yesterday/postgres.sql.gzip-1--rsyncable.yesterday.gz
  if [ -s "$FNEW" ]; then
    # if latest backup is 240+ minutes old and 10GiB+, save it as yesterday's
    if [ 1 = "$(find "$FNEW" -mmin +240 -size +10G -print | wc -l)" ]; then
      ln -f "$FNEW" "$FOLD"
    fi
  fi
  
  rm -f ./postgres.sql.gzip-1--rsyncable.latest.gz
  docker run \
  --rm \
  --log-driver=none \
  --network=matrix \
  --env-file=/matrix/postgres/env-postgres-psql \
  postgres:13.1-alpine \
  pg_dumpall -h matrix-postgres \
  | pigz --stdout --fast --blocksize 16384 --independent --processes 2 --rsyncable \
  > ./postgres.sql.gzip-1--rsyncable.latest.gz
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

FILE_SIZE=$(stat -c '%s' /matrix/backup/snapshot-latest/postgres.sql.gzip-1--rsyncable.latest.gz)
DATE_TIME=$(date '+%F_%H:%M:%S')

# borgmatic timings:
# awk '{if ($11==0) print $1,$13,"-",$7,"=",($13-$7)/60, "minutes";}' ~/snapshot-borg.log

# If borgmatic fails, check and try again later
#export BORG_REPO=kvm4:/backup/borg-perthchat BORG_PASSPHRASE=$(awk '/^ *encryption_passphrase:/ {print $NF}' ~/.config/borgmatic/config.yaml)
# time borg info; time borg list
# time borgmatic -v1

echo "$DATE_TIME $0: Snapshot (returned $DOCKERRC at $DOCKER_ELAPSED seconds)+ BorgBackup (returned $BORGMATICRC at $BORGMATIC_ELAPSED seconds) completed, database.gz size: $FILE_SIZE" >> /matrix/awx/backup.log

