#!/bin/bash
#
# Auteur : José Alves
# Description : script qui recupere les ip privés des instances de l'ASG COUCHBASE et redémarre les sync_gateway
#
#############################


ASG="PROD-COUCHBASE-SYNC-GATEWAY-DCP-20181030"
INSTANCE_FILE="instances_ascaling_sync.txt"
RESULT=$(/usr/bin/aws autoscaling describe-auto-scaling-groups --output=text --auto-scaling-group-name $ASG |grep INSTANCES | cut -f4) #> $INSTANCE_FILE
#RESULT=$(cut -f4  $INSTANCE_FILE)

IPADDR="adress_sg.txt"
echo '' > $IPADDR
NB_SG=$(/usr/bin/aws autoscaling describe-auto-scaling-groups --output=text --auto-scaling-group-name $ASG |grep INSTANCES | cut -f4 |wc -l)
echo "$NB_SG instances actives"

for i in ${RESULT}
do
/usr/bin/aws ec2 describe-instances --instance-ids $i --filters "Name=vpc-id, Values="vpc-cbcc69ae"" --query "Reservations[*].Instances[*].PrivateIpAddress" --output=text >> $IPADDR

done

#/usr/bin/systemctl restart sync_gateway.service

for s in `cat $IPADDR`
do
        ssh -o BatchMode='yes' ${s} "hostname ; /usr/bin/systemctl restart sync_gateway.service"
        sleep 20
done
