#!/bin/bash
AMI=ami-01faf8de678b6d856
SG_ID=sg-0b677afd1b217e8ef
INSTANCES=("mongodb" "redis" "mysql" "cart" "catalogue" "payment" "shipping" "user" "rabbitmq" "dispatch" "web")
ZONE_ID=Z07187862EB134EMJD6GR
DOMAIN_NAME="bpix.online"

for i in "${INSTANCES[@]}"
do
if [ $i == "mongodb"] || [ $i == "mysql"] || [ $i == "shipping"]
then 
INSTANCE_TYPE="t3.small"
else 
INSTANCE_TYPE="t2.micro"
fi

IP_ADDRESS= $(aws ec2 run-instances --image-id ami-01faf8de678b6d856 --instance-type $INSTANCE_TYPE --security-group-ids sg-0b677afd1b217e8ef --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" --query 'Instances[0].PrivateIpAddress' --output text)
    echo "$i: $IP_ADDRESS"

    aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    --change-batch
 
 {
        "Comment": "Creating a record set for cognito endpoint"
        ,"Changes": [{
        "Action"              : "UPSERT"
        ,"ResourceRecordSet"  : {
            "Name"              : "'$i'.'$DOMAIN_NAME'"
            ,"Type"             : "A"
            ,"TTL"              : 1
            ,"ResourceRecords"  : [{
                "Value"         : "'$IP_ADDRESS'"
            }]
        }
        }]
    }
        '
done



