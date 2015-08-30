#!/bin/bash -x
DIR=$(dirname $0)
cp ${DIR}/puppet-dashboard.service /etc/systemd/system/
cp ${DIR}/puppet-dashboard-workers.service /etc/systemd/system/
systemctl daemon-reload
