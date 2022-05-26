if [ $# == 0 ]; then
  echo "Expected 1 argument: the company name"
  exit
fi
COMPANY_NAME=$1
. $COMPANY_NAME/tmp/config-context.sh
touch $COMPANY_NAME/tmp/join
helm show values pharmaledger-imi/quorum-node > $qnValuesPath
echo "deployment:" >>  $COMPANY_NAME/tmp/deployment.yaml
echo "company: \"$COMPANY_NAME\"" >>  $COMPANY_NAME/tmp/deployment.yaml
sed -i 's/\(company\)/\  \1/' $COMPANY_NAME/tmp/deployment.yaml
echo "network_name: \"$NETWORK_NAME\"" >>  $COMPANY_NAME/tmp/deployment.yaml
sed -i 's/\(network_name\)/\  \1/' $COMPANY_NAME/tmp/deployment.yaml

helm pl-plugin --joinNetwork -i $qnValuesPath $joinNetworkInfo $ghInfoPath $qnInfoPath $COMPANY_NAME/tmp/deployment.yaml -o $COMPANY_NAME/tmp

helm upgrade --install qn-0 pharmaledger-imi/quorum-node -f $qnValuesPath -f $ghInfoPath -f $qnInfoPath -f $joinNetworkInfo -f $COMPANY_NAME/tmp/deployment.yaml --set-file use_case.joinNetwork.plugin_data_common=$COMPANY_NAME/tmp/join-network.plugin.json,use_case.joinNetwork.plugin_data_secrets=$COMPANY_NAME/tmp/join-network.plugin.secrets.json && sleep 30
echo $qnInfoPath
cat $qnInfoPath
qnPort=$(cat $qnInfoPath | grep enode_address_port: | awk '{print $2}' | tr -d '"')
echo $qnPort
enodeAddress=$(kubectl get svc | grep $qnPort | awk '{print $4}')
echo $enodeAddress
enodeAddress="enode_address: \"$enodeAddress\""
echo $enodeAddress
echo $enodeAddress >>  $COMPANY_NAME/tmp/deployment.yaml
sed -i 's/\(enode_address\)/\  \1/' $COMPANY_NAME/tmp/deployment.yaml
helm upgrade --install qn-0 pharmaledger-imi/quorum-node -f $qnValuesPath -f $ghInfoPath -f $qnInfoPath -f $joinNetworkInfo -f $COMPANY_NAME/tmp/deployment.yaml --set-file use_case.joinNetwork.plugin_data_common=$COMPANY_NAME/tmp/join-network.plugin.json,use_case.joinNetwork.plugin_data_secrets=$COMPANY_NAME/tmp/join-network.plugin.secrets.json
