#!/bin/bash

ZONE_ID="Z0738852208EFDOYXFTUB"
DOMAIN_NAME="opsora.space"


SERVICES=("mongodb" "mysql" "shipping" "catalogue" "frontend" "redis" "user" "cart" "rabbitmq" "payment" "dispatch")

echo "Terminating Roboshop services instancs.."

for service in "${SERVICES[@]}"; do

  INSTANCE_ID=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=$service" "Name=instance-state-name,Values=running" \
    --query 'Reservations[*].Instances[*].InstanceId' \
    --output text)

  if [ -n "$INSTANCE_ID" ]; then


   if [ "$service" == "frontend" ]; then
     
     IP=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=$service" \
    --query "Reservations[*].Instances[*].PublicIpAddress" \
    --output text)
    RECORD_NAME="$DOMAIN_NAME"

   else 
      IP=$(
        aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=$service" \
    --query "Reservations[*].Instances[*].PrivateIpAddress" \
    --output text)
    RECORD_NAME="$service.$DOMAIN_NAME"

    fi

    echo " Terminating $service instance (ID: $INSTANCE_ID) "
    aws ec2 terminate-instances --instance-ids "$INSTANCE_ID"

  echo " Deleting Route53 record: $RECORD_NAME == $IP " 

  aws route53 change-resource-record-sets \
    --hosted-zone-id "$ZONE_ID" \
    --change-batch "
  {
  "Changes": [
    {
      "Action": "DELETE",
      "ResourceRecordSet": {
        "Name": "'$RECORD_NAME'",
        "Type": "A",
        "TTL": 1,
        "ResourceRecords": [
          {
            "Value": "'$IP'"
          }
        ]
      }
    }]
}"
else
     echo "No running instance found for $service, skipping..."
fi

done

echo "All instances terminated"

