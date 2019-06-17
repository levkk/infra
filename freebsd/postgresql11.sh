#!/bin/bash
#
# Setup PostgreSQL 11 on FreeBSD 12.
#
# Requirements:
#   - Bash
#   - Run this with a sudo user
#   - Internet connection
#

# Postgres data will go here
DATA_DIR="/pool/database/postgres/11/data"

# Update these to reflect the disks available
DISKS="/dev/da1 /dev/da2"

# Go root
sudo -i

# Update packages
pkg update

# Install postgresql 11
pkg install -y postgresql11-server

# Enable postgresql in rc
cp /etc/rc.conf /etc/rc.conf.backup

cat >> /etc/rc.conf <<-EOF
postgresql_enable="YES"
postgresql_data="$DATA_DIR"
EOF

# Setup ZFS
# TODO: decide on the pool RAID type. raidz1 scares people,
# probably with just cause.
# vdev types: https://www.freebsd.org/doc/handbook/zfs-term.html#zfs-term-vdev
zpool create pool raidz1 $DISKS

zfs create pool/database
zfs set compression=gzip pool/database

# Data dir
mkdir -p $DATA_DIR
chown postgres:postgres $DATA_DIR

# Init postgres
su postgres -c "initdb $DATA_DIR"

# Start postgres
service postgresql start

# Done!
exit 0
