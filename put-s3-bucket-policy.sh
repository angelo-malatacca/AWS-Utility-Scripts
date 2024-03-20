#!/bin/bash

# This script is designed to write a bucket policy using a json file named as the bucket itself

# Get list of S3 buckets from Amazon Web Services

# s3_bucket_list=$(aws s3api list-buckets --query 'Buckets[*].Name' | sed -e 's/[][]//g' -e 's/"//g' -e 's/,//g' -e '/^$/d' -e 's/^[ \t]*//;s/[ \t]*$//')
s3_bucket_list=$(aws s3api list-buckets --query 'Buckets[*].Name' | sed -e 's/[][]//g' -e 's/"//g' -e 's/,//g')

# Loop through the list of S3 buckets and write the individual bucket's policy.

for bucket in $(echo "$s3_bucket_list")
do
    aws s3api put-bucket-policy --bucket "$bucket" --policy file://$bucket-policy.json
    echo "The S3 bucket '$bucket' policy has been written."
    echo ""
done