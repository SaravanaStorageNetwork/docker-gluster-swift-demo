#!/bin/bash

. ./util.sh

#Verify GET/PUT
desc "Get IP address of corresponding pod"
run "ssh centos-master kubectl describe pod gluster-object  | grep "IP:" |  sed -E 's/IP:[[:space:]]+//'"
ip_address=$(ssh centos-master kubectl describe pod gluster-object  | grep "IP:" |  sed -E 's/IP:[[:space:]]+//')

# add s3curl.pl for testing
export PATH=$PATH:/root/s3-curl/

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

