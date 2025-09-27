#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-0dfa2ec6d3272ffeb"
DOMAIN_NAME="awsdevops.fun"
ZONE_ID="Z02792703IESGDED1SCJO"



for INSTANCE in $@; do
    INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI_ID --instance-type t3.micro --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$INSTANCE}]" --query 'Instances[0].InstanceId' --output text)
    if [ $INSTANCE != "frontend" ]; then
        #get privateip
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text)	
        RECORD_NAME="${INSTANCE}.${DOMAIN_NAME}"
    else 
        #get publicip
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[*].Instances[*].PublicIpAddress' --output text)
        RECORD_NAME="${DOMAIN_NAME}"
    fi
    
    echo " $INSTANCE : $INSTANCE_ID : $IP"

    # creating and updating records if already created 
    aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    --change-batch '
    {
        "Comment": "Updating record set"
        ,"Changes": [{
        "Action"              : "UPSERT"
        ,"ResourceRecordSet"  : {
            "Name"              : "'$RECORD_NAME'"
            ,"Type"             : "A"
            ,"TTL"              : 1
            ,"ResourceRecords"  : [{
                "Value"         : "'$IP'"
            }]
        }
        }]
    }
    '
done


