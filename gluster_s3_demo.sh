#!/bin/bash

. ./util.sh

# Setup Gluster
desc "Starting glusterd service in gant"
run "systemctl start glusterd.service"

desc "Check peer status"
run "gluster peer status"

desc "Note: Passwordless ssh is setup to gfvm3"

desc "Starting glusterd service in gfvm3"
run "ssh root@gfvm3 systemctl start glusterd.service"

desc "Check glusterd service in gfvm3"
run "ssh root@gfvm3 systemctl status glusterd.service"

desc "Add peer gfvm3"
run "gluster peer probe gfvm3"

desc "Check peer status"
run "gluster peer status"

desc "Create a simple distribute volume"
run "gluster vol create tv1  gant:/opt/volume_test/tv_1/b1/ gfvm3:/opt/volume_test/tv_1/b2  force "

desc "Start the volume"
run "gluster vol start tv1"

desc "Check volume status"
run "gluster vol status"

desc "mount volume in a directory"
run "mkdir -p /mnt/gluster-object/tv1"
run "mount -t glusterfs gant:/tv1 /mnt/gluster-object/tv1"

desc "check whether mounted"
run "mount | grep mnt"

# Setup Docker Gluster S3
rm -rf docker-gluster-s3

desc "Clone docker-gluster-s3 repo"
run "git clone https://github.com/SaravanaStorageNetwork/docker-gluster-s3.git"
cd docker-gluster-s3

desc "Check whether docker service running"
run "sudo systemctl status docker.service"

desc "Build a new image"
run "docker build --rm --tag gluster-s3:dev .  "

desc "Run docker container with bind mount of gluster volume directory"
run "docker run -d --privileged  -v /sys/fs/cgroup/:/sys/fs/cgroup/:ro -p 8080:8080 -v /mnt/gluster-object:/mnt/gluster-object    gluster-s3:dev"

desc "Get corresponding container id"
run "docker ps -q"

#Verify GET/PUT
desc "Get IP address of corresponding container id"
run "docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'  "$(docker ps -q)""

ip_address=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'  "$(docker ps -q)")

# add s3curl.pl for testing
export PATH=$PATH:/home/blr/sarumuga/workspace/projects/gluster/repos/gerrit_gluster/glusterfs.master_6june/gluster_swift_stuff/s3_access/s3-curl/

desc "Verify PUT of a Bucket"
run "s3curl.pl --debug --id 'tv1' --key 'test' --put /dev/null  -- -k -v  http://$ip_address:8080/bucket1"
desc " "
desc "Verify PUT of a Bucket - done"

desc "Verify object PUT request. Create a simple file with some content"
run "touch first_file.txt"
run "echo \"Hello Gluster - for S3 access demo\" > first_file.txt"

run "s3curl.pl --debug --id 'tv1' --key 'test' --put  ./first_file.txt -- -k -v -s http://$ip_address:8080/bucket1/test_object.txt"
desc "Verify object PUT request - done"

desc "Verify listing objects in the container "
run "s3curl.pl --debug --id 'tv1' --key 'test'   -- -k -v -s http://$ip_address:8080/bucket1/"
desc "Verify listing objects in the container - done "

desc "Verify object GET request"
run "s3curl.pl --debug --id 'tv1' --key 'test'   -- -o test_object.txt http://$ip_address:8080/bucket1/test_object.txt"
desc "Verify object GET request - done"

desc "Verify received Object"
run "cat test_object.txt"

desc "Verify object Delete request"
run "s3curl.pl --debug --id 'tv1' --key 'test' --delete  --  http://$ip_address:8080/bucket1/test_object.txt"
desc "Verify object Delete request - done"
desc " "

desc "Verify bucket Delete request"
run "s3curl.pl --debug --id 'tv1' --key 'test' --delete  --  http://$ip_address:8080/bucket1"
desc "Verify object Delete request - done"
desc " "

desc "Gluster-object now available in Docker hub! "
desc "Visit: https://hub.docker.com/r/gluster/gluster-object/"
