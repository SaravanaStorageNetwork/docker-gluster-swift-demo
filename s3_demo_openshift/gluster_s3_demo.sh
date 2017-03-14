#!/bin/bash

. ./util.sh

#Verify GET/PUT
desc "Get IP address of corresponding gluster-s3 pod"

run "oc  get pods  -o wide  | grep glusters3 |  awk '{print \$6}'"
ip_address=$(oc  get pods  -o wide  | grep glusters3 |  awk '{print $6}')


# add s3curl.pl for testing
export PATH=$PATH:/root/s3-curl/

desc "Verify PUT of a Bucket"
run "s3curl.pl --debug --id 'tv1' --key 'test' --put /dev/null  -- -k -v  http://$ip_address:8080/bucket1"
desc " "
desc "Verify PUT of a Bucket - done"

desc "Verify object PUT request. Create a simple file with some content"
run "touch my_object.jpg"
run "echo \"Hello Gluster from OpenShift - for S3 access demo\" > my_object.jpg"

run "s3curl.pl --debug --id 'tv1' --key 'test' --put  my_object.jpg  -- -k -v -s http://$ip_address:8080/bucket1/my_object.jpg "
desc "Verify object PUT request - done"

desc "Verify listing objects in the container "
run "s3curl.pl --debug --id 'tv1' --key 'test'   -- -k -v -s http://$ip_address:8080/bucket1/"
desc "Verify listing objects in the container - done "

desc "Verify object GET request"
run "s3curl.pl --debug --id 'tv1' --key 'test'   -- -o test_object.jpg http://$ip_address:8080/bucket1/my_object.jpg"
desc "Verify object GET request - done"

desc "Verify received Object"
run "cat test_object.jpg"

desc "Verify object Delete request"
run "s3curl.pl --debug --id 'tv1' --key 'test' --delete  --  http://$ip_address:8080/bucket1/my_object.jpg"
desc "Verify object Delete request - done"
desc " "

desc "Verify bucket Delete request"
run "s3curl.pl --debug --id 'tv1' --key 'test' --delete  --  http://$ip_address:8080/bucket1"
desc "Verify object Delete request - done"
desc " "
