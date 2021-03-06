#!/bin/bash -x
rancher_server_ip=${1:-192.168.1.10}
default_password=${2:-password}
default_cluster=${3:-quickstart}
rancher_server_version=${4:-stable}
kubernetes_version=${5:-v1.11.2-rancher1-1}
registry_prefix="rancher"
curl_prefix="appropriate"

rancher_command="rancher/rancher:$rancher_server_version" 


echo Installing Rancher Server
# 安装 rancher
sudo docker run -d --restart=always \
 -p 443:443 \
 -p 80:80 \
 -v /host/rancher:/var/lib/rancher \
 --restart=unless-stopped \
 --name rancher-server \
$rancher_command

# sleep 50
# wait until rancher server is ready
while true; do
  wget --no-check-certificate -T 5 -c https://localhost/ping && break
  sleep 5
done

# Login
LOGINRESPONSE=$(docker run --net=host \
    --rm \
    $curl_prefix/curl \
    -s "https://127.0.0.1/v3-public/localProviders/local?action=login" -H 'content-type: application/json' --data-binary '{"username":"admin","password":"admin"}' --insecure)

LOGINTOKEN=$(echo $LOGINRESPONSE | jq -r .token)

# Change password
docker run --net=host \
    --rm \
    $curl_prefix/curl \
     -s "https://127.0.0.1/v3/users?action=changepassword" -H 'content-type: application/json' -H "Authorization: Bearer $LOGINTOKEN" --data-binary '{"currentPassword":"admin","newPassword":"'$default_password'"}' --insecure

# Create API key
APIRESPONSE=$(docker run --net host \
    --rm \
    $curl_prefix/curl \
     -s "https://127.0.0.1/v3/token" -H 'content-type: application/json' -H "Authorization: Bearer $LOGINTOKEN" --data-binary '{"type":"token","description":"automation","name":""}' --insecure)

# Extract and store token
APITOKEN=$(echo $APIRESPONSE | jq -r .token)

# Configure server-url
SERVERURLRESPONSE=$(docker run --net host \
    --rm \
    $curl_prefix/curl \
     -s 'https://127.0.0.1/v3/settings/server-url' -H 'content-type: application/json' -H "Authorization: Bearer $APITOKEN" -X PUT --data-binary '{"name":"server-url","value":"https://'$rancher_server_ip'"}' --insecure)

# Create cluster
CLUSTERRESPONSE=$(docker run --net host \
    --rm \
    $curl_prefix/curl \
     -s 'https://127.0.0.1/v3/cluster' -H 'content-type: application/json' -H "Authorization: Bearer $APITOKEN" \
     --data-binary "{\"type\":\"cluster\",\"rancherKubernetesEngineConfig\":{\"ignoreDockerVersion\":false,\"sshAgentAuth\":false,\"type\":\"rancherKubernetesEngineConfig\",\"kubernetesVersion\":\"$kubernetes_version\",\"authentication\":{\"type\":\"authnConfig\",\"strategy\":\"x509\"},\"network\":{\"type\":\"networkConfig\",\"plugin\":\"flannel\",\"flannelNetworkProvider\":{\"iface\":\"eth1\"},\"calicoNetworkProvider\":null},\"ingress\":{\"type\":\"ingressConfig\",\"provider\":\"nginx\"},\"services\":{\"type\":\"rkeConfigServices\",\"kubeApi\":{\"podSecurityPolicy\":false,\"type\":\"kubeAPIService\"},\"etcd\":{\"type\":\"etcdService\",\"extraArgs\":{\"heartbeat-interval\":500,\"election-timeout\":5000}}}},\"name\":\"$default_cluster\"}" --insecure)

# CLUSTERRESPONSE=$(docker run --net host \
#     --rm \
#     $curl_prefix/curl \
#      -s 'https://127.0.0.1/v3/cluster' -H 'content-type: application/json' -H "Authorization: Bearer $APITOKEN" \
#      --data-binary '{
#          "type":"cluster",
#          "name":"'$default_cluster'",
#          "dockerRootDir":"/var/lib/docker",
#          "enableClusterAlerting":false,
#          "enableClusterMonitoring":false,
#          "enableNetworkPolicy":false,
#          "localClusterAuthEndpoint":{
#              "enabled":true,
#              "type":"localClusterAuthEndpoint"
#          },
#          "rancherKubernetesEngineConfig":{
#              "addonJobTimeout":30,
#              "authentication":{
#                  "strategy":"x509",
#                  "type":"authnConfig"
#              },
#              "ignoreDockerVersion":true,
#              "ingress":{
#                  "provider":"nginx",
#                  "type":"ingressConfig"
#              },
#              "kubernetesVersion":"'$kubernetes_version'",
#              "monitoring":{
#                  "provider":"metrics-server",
#                  "type":"monitoringConfig"
#              },
#              "network":{
#                  "options":{
#                      "flannel_backend_type":"vxlan"
#                  },
#                  "plugin":"canal",
#                  "type":"networkConfig"
#              },
#              "privateRegistries":[
#                  {
#                      "isDefault":true,"type":
#                      "privateRegistry",
#                      "url":""
#                  }
#              ],
#              "services":{
#                  "etcd":{
#                      "backupConfig":{
#                          "enabled":true,
#                          "intervalHours":12,
#                          "retention":6,
#                          "type":"backupConfig"
#                      },
#                      "creation":"12h",
#                      "extraArgs":{
#                          "election-timeout":5000,
#                          "heartbeat-interval":500
#                      },
#                      "retention":"72h",
#                      "snapshot":false,
#                      "type":"etcdService"
#                  },
#                  "kubeApi":{
#                      "alwaysPullImages":false,
#                      "podSecurityPolicy":false,
#                      "serviceNodePortRange":"30000-32767",
#                      "type":"kubeAPIService"
#                  },
#                  "type":"rkeConfigServices"
#              },
#              "sshAgentAuth":false,
#              "type":"rancherKubernetesEngineConfig"
#          }
#      }' --insecure)

# Extract clusterid to use for generating the docker run command
CLUSTERID=`echo $CLUSTERRESPONSE | jq -r .id`

# Generate cluster registration token
CLUSTERREGTOKEN=$(docker run --net=host \
    --rm \
    $curl_prefix/curl \
     -s 'https://127.0.0.1/v3/clusterregistrationtoken' -H 'content-type: application/json' -H "Authorization: Bearer $APITOKEN" --data-binary '{"type":"clusterRegistrationToken","clusterId":"'$CLUSTERID'"}' --insecure)
