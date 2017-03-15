#!/bin/bash

. ./util.sh

desc "Create endpoint"
run "cat gluster-endpoints.yaml"
run "oc create -f gluster-endpoints.yaml"

desc "Create service"
run "cat gluster-service.json"
run "oc create -f gluster-service.json"

desc "Create gluster volume using heketi-cli "
run "heketi-cli volume create --size=1   --persistent-volume   --persistent-volume-endpoint=glusterfs-cluster --name=tv1 | tee pv.json"

desc "Create persistent volume "
run "cat ./pv.json"
run "oc create -f ./pv.json"

desc "Create persistent volume claim "
run "cat ./pvc.yaml"
run "oc create -f ./pvc.yaml"

desc "Create gluster-object with S3 access pod with pvc created above"
run "cat ./glusters3_pod.yaml"
run "oc create -f ./glusters3_pod.yaml"

desc "Expose gluster-object pod"
run "oc expose pod glusters3 --port=8080  --target-port=8080 --name=glusters3service"

run "oc describe svc glusters3service"

