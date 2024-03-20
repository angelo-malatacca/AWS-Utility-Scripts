#!/bin/bash

# This script is designed to retrieve the bucket policy of all S3 buckets associated with an AWS account
# if the policy exists it writes it to a json file, otherwise it jumps to the next bucket

# Get list of S3 buckets from Amazon Web Services

# s3_bucket_list=$(aws s3api list-buckets --query 'Buckets[*].Name' | sed -e 's/[][]//g' -e 's/"//g' -e 's/,//g' -e '/^$/d' -e 's/^[ \t]*//;s/[ \t]*$//')
s3_bucket_list=$(aws s3api list-buckets --query 'Buckets[*].Name' | sed -e 's/[][]//g' -e 's/"//g' -e 's/,//g')

# Loop through the list of S3 buckets and retrieve the individual bucket's policy.

for bucket in $(echo "$s3_bucket_list")
do
    bucket_policy=$(aws s3api get-bucket-policy --bucket "$bucket" --query Policy 2>/dev/null)
        if [[ -z "$bucket_policy" ]]; then
            echo "The S3 bucket '$bucket' does not have a policy."
            echo ""
        else
            aws s3api get-bucket-policy --bucket "$bucket" --query Policy --output text | jq > $bucket-policy.json
            echo "S3 bucket '$bucket' policy written to $bucket-policy.json"
            echo ""
        fi
done