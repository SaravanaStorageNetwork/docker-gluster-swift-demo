#!/bin/bash

. ./util.sh

# Setup Gluster
desc "Starting glusterd service"
run "systemctl start glusterd.service"

desc "Create a simple distribute volume"
run "gluster vol create tv1  gant:/opt/volume_test/tv_1/b1/ gant:/opt/volume_test/tv_1/b2  force "

desc "Start the volume"
run "gluster vol start tv1"

desc "Check volume status"
run "gluster vol status"

desc "mount volume in a directory"
run "mkdir -p /mnt/gluster-object/tv1"
run "mount -t glusterfs gant:/tv1 /mnt/gluster-object/tv1"

desc "check whether mounted"
run "mount | grep mnt"

# Setup Docker Gluster Swift
rm -rf docker-gluster-swift

desc "Clone docker-gluster-swift repo"
run "git clone https://github.com/prashanthpai/docker-gluster-swift.git"
cd docker-gluster-swift

desc "Check whether docker service running"
run "sudo systemctl status docker.service"

desc "Build a new image"
run "docker build --rm --tag prashanthpai/gluster-swift:dev .  "

desc "Run docker container with bind mount of gluster volume directory"
run "docker run -d -p 8080:8080 -v /mnt/gluster-object:/mnt/gluster-object -e GLUSTER_VOLUMES="tv1" prashanthpai/gluster-swift:dev"

desc "Get corresponding container id"
run "docker ps -q"

#Verify GET/PUT
desc "Get IP address of corresponding container id"
run "docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'  "$(docker ps -q)""

ip_address=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'  "$(docker ps -q)")

desc "Test PUT of a container"
run "curl -v -X PUT http://$ip_address:8080/v1/AUTH_tv1/mycontainer"
desc " "
desc "Test PUT of a container Done"

desc "Verify object PUT request. Create a simple file with some content"
run "touch first_file.txt"
run "echo \"Hello Gluster Swift demo\" > first_file.txt"

run "curl -v -X PUT -T first_file.txt http://$ip_address:8080/v1/AUTH_tv1/mycontainer/first_file_test.txt"
desc "Verify object PUT request Done"

desc "Verify listing objects in the container "
run "curl -v -X GET  http://$ip_address:8080/v1/AUTH_tv1/mycontainer"
desc "Verify listing objects in the container Done "

desc "Verify object GET request"
run "curl -v -X GET -o newfile  http://$ip_address:8080/v1/AUTH_tv1/mycontainer/first_file_test.txt"
desc "Verify object GET request Done"

desc "Verify GET file"
run "cat newfile"
