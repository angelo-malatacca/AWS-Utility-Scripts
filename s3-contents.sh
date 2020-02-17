#!/bin/bash

echo ""
echo "This script show you all buckets"
echo "and ask the contents of which bucket you want to see"
echo ""

aws s3 ls

echo ""
echo ""

echo -n "Enter bucket name and press [ENTER]: "
read bucket
echo ""
echo "Bucket $bucket contains:"
aws s3 ls s3://$bucket --recursive --human-readable --summarize