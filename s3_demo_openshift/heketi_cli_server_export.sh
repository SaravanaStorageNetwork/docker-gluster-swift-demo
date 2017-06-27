
export HEKETI_CLI_SERVER=$(oc describe svc/heketi | grep Endpoints | awk '{print "http://"$2}'    )
