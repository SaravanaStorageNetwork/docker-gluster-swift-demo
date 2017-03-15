oc delete svc glusters3service
sleep 2
oc delete -f ./glusters3_pod.yaml
sleep 2
oc delete -f ./pvc.yaml
sleep 2
oc delete -f ./pv.json
sleep 2

heketi-cli  volume list  | grep tv1  

heketi-cli  volume list  | grep tv1 | awk '{print $1}' 
volid=`heketi-cli  volume list  | grep tv1  | awk '{print $1}' |  cut -d: -f2- `
echo $volid
heketi-cli volume delete $volid

oc delete -f gluster-endpoints.yaml

oc delete -f gluster-service.json

