#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-0dfa2ec6d3272ffeb"



for INSTANCE in $@; do
    INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI_ID --instance-type t3.micro --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$INSTANCE}]" --query 'Instances[0].InstanceId' --output text)
    if [ $INSTANCE_ID != "frontend" ]; then
        #get privateip
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text)	
    else 
        #get publicip
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[*].Instances[*].PublicIpAddress' --output text)
    fi
    
    echo "$INSTANCE_ID"
    echo "$IP"
done


