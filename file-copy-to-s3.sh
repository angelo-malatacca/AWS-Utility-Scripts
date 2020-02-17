#!/bin/bash

echo ""
echo "This script show you all buckets and ask which"
echo "folder in which bucket you want to copy"
echo ""

aws s3 ls

echo ""
echo ""

echo -n "Enter folder name and press [ENTER]: "
read folder
echo -n "Enter bucket name and press [ENTER]: "
read bucket


aws s3 cp $folder s3://$bucket --recursive