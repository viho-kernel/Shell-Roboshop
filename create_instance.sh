#!/bin/bash

AMI_ID="ami-0220d79f3f480ecf5"
SG_ID="sg-0d34a14d6eba15d9d"
ZONE_ID="Z0738852208EFDOYXFTUB"
DOMAIN="opsora.space"

for instance in $@

do 
   
   INSTANCE_ID=$(

    if [ $instance == 'mongodb' ]; then

    aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type t3.medium \
    --security-group-ids $SG_ID \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
    --query 'Instances[0].InstanceId' \
    --output text

   

   elif [ $instance == 'catalogue' ]; then
    
    aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type t3.micro \
    --security-group-ids $SG_ID \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
    --query 'Instances[0].InstanceId' \
    --output text

    fi

   )
    echo "Instance ID of ${instance} is ${INSTANCE_ID}"

    IP=$(
    if [ $instance == 'frontend']; then
    aws ec2 describe-instances \
    --filters "Name=instance-id,Values=$INSTANCE_ID" \
    --query 'Reservations[].Instances[].PublicIpAddress' \
    --output text

    else
    aws ec2 describe-instances \
    --filters "Name=instance-id,Values=$INSTANCE_ID" \
    --query 'Reservations[].Instances[].PrivateIpAddress' \
    --output text

    fi
    )

    echo " IP Addresses of $instance is ${IP}"


done