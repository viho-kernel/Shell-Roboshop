aws credentials get saved in cd .aws/ by defaulty
cd .aws/credentials --> here is where your credentials get saved

All parameters can be taken into script using $@. So all parameters you're passing will come up.

to get instance id
aws ec2 run-instances \
    --image-id ami-0abcdef1234567890 \
    --instance-type t3.micro \
    --security-group-ids $SG_ID \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=MyInstanceName}]' \
     --query 'Instances[0].InstanceId' \
    --output text

to get public ip address
aws ec2 describe-instances \
    --filters "Name=instance-id,Values=$INSTANCE_ID" \
    --query 'Reservations[].Instances[].PublicIpAddress' \
    --output text

to get private ip address
aws ec2 describe-instances \
    --filters "Name=instance-id,Values=$INSTANCE_ID" \
    --query 'Reservations[].Instances[].PrivateIpAddress' \
    --output text
to change aws router 53 hosted zone
aws route53 change-resource-record-sets \
--hosted-zone-id Z1R8UBAEXAMPLE \
--change-batch '
{
  "Comment": "Updating A record",
  "Changes": [
    {
      "Action": "CREATE",
      "ResourceRecordSet": {
        "Name": " '$RECORD_NAME' ",
        "Type": "A",
        "TTL": 1,
        "ResourceRecords": [
          {
            "Value": $IP
          }
        ]
      }
    }
  ]
}

'


ORDER
1) Declare variables SECURITY GROUP, AMI ID, Hostedzone ID, Hosted Zone Name
2) write a for loop and pass all arguments and get the ip addres queroed from them
3) query the ip address and store it in a variable.
4) write an ip block comparing if instance name == frontend then take only public ip or else take private ip alone. Catch those ip addresses in variables
5) Write a block to write and update Route 53 write the necessary json file
6) Create the record name in same loop of public ip address and private ip address