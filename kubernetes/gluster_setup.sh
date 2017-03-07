#!/bin/bash

. ./util.sh

# Setup Gluster
desc "Starting glusterd service in centos-master"
run "systemctl start glusterd.service"

desc "Check peer status"
run "gluster peer status"

desc "Starting glusterd service in centos-minion"
run "ssh centos-minion systemctl start glusterd.service"

desc "Add peer centos-master"
run "gluster peer probe centos-minion"

desc "Check peer status"
run "gluster peer status"

desc "Create a simple distribute volume"
run "gluster vol create tv1  centos-master:/opt/volume_test/tv_1/b1/ centos-minion:/opt/volume_test/tv_1/b2  force "

desc "Start the volume"
run "gluster vol start tv1"

desc "Check volume status"
run "gluster vol status"

desc "mount volume in a directory"
run "ssh centos-minion mkdir -p /mnt/gluster-object/tv1"
run "ssh centos-minion mount -t glusterfs centos-minion:/tv1 /mnt/gluster-object/tv1"

desc "check whether mounted"
run "ssh centos-minion mount | grep mnt"

