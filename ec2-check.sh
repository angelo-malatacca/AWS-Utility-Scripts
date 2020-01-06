#!/bin/bash
echo ""
echo "This script show you all the instances"
echo "in all the AWS available regions"
echo ""


for region in `aws ec2 describe-regions --output text | cut -f4`
do
     echo -e "\nListing Instances in region: $region:"
     aws ec2 describe-instances --region $region | jq '.Reservations[] | ( .Instances[] | {state: .State.Name, "Launch time": .LaunchTime, Name: .Tags[].Value, "Instance Id": .InstanceId, "InstanceType": .InstanceType, Key: .KeyName, "Availability zone": .Placement.AvailabilityZone, "Private IP": .PrivateIpAddress, "Public Ip": .PublicIpAddress})'
done