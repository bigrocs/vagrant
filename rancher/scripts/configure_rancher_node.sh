#!/bin/bash -x
rancher_server_ip=${1:-192.168.1.10}
default_password=${2:-password}
default_cluster=${3:-quickstart}
roleflags=${4:---worker}

agent_ip=`ip addr show eth1 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1`

curlprefix="appropriate"
protocol="http"

# Login
LOGINRESPONSE=$(docker run \
    --rm \
    $curlprefix/curl \
    -s "https://$rancher_server_ip/v3-public/localProviders/local?action=login" -H 'content-type: application/json' --data-binary '{"username":"admin","password":"'$default_password'"}' --insecure)
LOGINTOKEN=$(echo $LOGINRESPONSE | jq -r .token)

# Test if cluster is created
while true; do
  ENV_STATE=$(docker run \
    --rm \
    $curlprefix/curl \
      -sLk \
      -H "Authorization: Bearer $LOGINTOKEN" \
      "https://$rancher_server_ip/v3/clusterregistrationtoken?name=$default_cluster" | jq -r '.data[].nodeCommand')

  if [[ "$ENV_STATE" != "null" ]]; then
    break
  else
    sleep 5
  fi
done

CLUSTERRESPONSE=$(docker run --net host \
    --rm \
    $curlprefix/curl -s "https://$rancher_server_ip/v3/clusters?name=$default_cluster" -H 'content-type: application/json' -H "Authorization: Bearer $LOGINTOKEN" --insecure)

# Extract clusterid to use for generating the docker run command
CLUSTERID=`echo $CLUSTERRESPONSE | jq -r .data[].id`

# Get token
AGENTCMD=$(docker run --net host \
    --rm \
    $curlprefix/curl -s "https://$rancher_server_ip/v3/clusterregistrationtoken?id=$CLUSTERID" -H 'content-type: application/json' -H "Authorization: Bearer $LOGINTOKEN" --insecure | jq -r .data[].nodeCommand  | head -1)

# Show the command
COMPLETECMD="$AGENTCMD $roleflags --internal-address $agent_ip --address $agent_ip "
$COMPLETECMD
