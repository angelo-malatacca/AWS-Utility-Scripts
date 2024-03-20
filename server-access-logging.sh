#!/bin/bash

# This script is designed to check the server access logging status of all S3 buckets associated with an AWS account

# Get list of S3 buckets from Amazon Web Services

# s3_bucket_list=$(aws s3api list-buckets --query 'Buckets[*].Name' | sed -e 's/[][]//g' -e 's/"//g' -e 's/,//g' -e '/^$/d' -e 's/^[ \t]*//;s/[ \t]*$//')
s3_bucket_list=$(aws s3api list-buckets --query 'Buckets[*].Name' | sed -e 's/[][]//g' -e 's/"//g' -e 's/,//g')

# Loop through the list of S3 buckets and check the individual bucket's server access logging status.

for bucket in $(echo "$s3_bucket_list")
do
  version_status=$(aws s3api get-bucket-logging --bucket "$bucket" | awk '/TargetBucket/ {print $2}' | sed 's/"//g' | sed 's/,//g')
   if [[ "$version_status" = "cloudops-bucket-access-logging" ]] || [[ "$version_status" = "cloudops-bucket-access-logging-east1" ]] || [[ "$version_status" = "cloudops-bucket-access-logging-eu-west-1" ]]; then

      # If the server access logging status replies with a destination bucket name, report that the S3 bucket has server access logging enabled.

      echo "The $bucket S3 bucket has server access logging enabled to bucket $version_status."
  else
      echo "The $bucket S3 bucket does not have server access logging enabled."
  fi
done