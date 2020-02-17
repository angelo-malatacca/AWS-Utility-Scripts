#!/bin/bash

echo ""
echo "This script is used to create a new AMI"
echo "using the AWS Imagebuilder service"
echo ""

# Complete all the requested information

Region=""
AccountID=""
ComponentName=""
ProjectName=""
VersionId="$(date | awk 'BEGIN {OFS = "."}{print $3, $6, $4}' | sed 's/\://' |sed 's/\://')"
# Select an IAM role to associate with the instance profile or Create a new role.
#As a starting point, you can use the following IAM role policies: 
#EC2InstanceProfileForImageBuilder and AmazonSSMManagedInstanceCore
RoleName=""
SecurityGroup=""
SubnetId=""
# You can enter an SNS topic ARN to be notified by the AWS Simple Notification Service (SNS)
SNSTopic="arn:aws:sns:"
DistributionName=$ProjectName


echo "----------------------------------"
echo "| Delete existing image pipeline |"
echo "----------------------------------"
aws imagebuilder delete-image-pipeline \
--image-pipeline-arn arn:aws:imagebuilder:$Region:$AccountID:image-pipeline/$DistributionName


# delete recipe if already exists
echo "----------------------------"
echo "| Deleting existing recipe |"
echo "----------------------------"
aws imagebuilder delete-image-recipe \
--image-recipe-arn arn:aws:imagebuilder:$Region:$AccountID:image-recipe/$ProjectName/$VersionId


# create new recipe
echo "-------------------"
echo "| Recipe Creation |"
echo "-------------------"
aws imagebuilder create-image-recipe \
--semantic-version $VersionId \
--name $ProjectName \
--parent-image arn:aws:imagebuilder:eu-west-1:aws:image/amazon-linux-2-x86/x.x.x \
# enter the arns of the components you want to install and the tests you want to perform
--components '[
        {"componentArn": "'arn:aws:imagebuilder:eu-west-1:aws:component/python-3-linux/1.0.0'"},
        {"componentArn": "'arn:aws:imagebuilder:eu-west-1:aws:component/simple-boot-test-linux/1.0.0'"},
        {"componentArn": "'arn:aws:imagebuilder:eu-west-1:aws:component/reboot-test-linux/1.0.0'"}
]'


# delete distribution configuration  if already exists
echo "------------------------------------------------"
echo "| Deleting existing distribution configuration |"
echo "------------------------------------------------"
aws imagebuilder delete-distribution-configuration \
--distribution-configuration-arn arn:aws:imagebuilder:$Region:$AccountID:distribution-configuration/$DistributionName


echo "-------------------------------------------"
echo "| Creating new distribution configuration |"
echo "-------------------------------------------"
aws imagebuilder create-distribution-configuration \
--name $ProjectName \
--description "ImageBuilder $ProjectName Distribution Configuration" \
--distributions '[
        {"region": "'$Region'",
            "amiDistributionConfiguration": {
                "name": "'$ProjectName'-output-AMI {{imagebuilder:buildDate}}",
                "description": "An example image name with parameter references",
                "amiTags": {
                    "KeyName": "{{ssm:parameter_name}}"
                },
                "launchPermission": {
                    "userIds": [
                        "'$AccountID'"
                    ]
                }
            }
        }
    ]'


# delete infrastructure configuration  if already exists
echo "--------------------------------------------------"
echo "| Deleting existing infrastructure configuration |"
echo "--------------------------------------------------"
aws imagebuilder delete-infrastructure-configuration \
--infrastructure-configuration-arn arn:aws:imagebuilder:$Region:$AccountID:infrastructure-configuration/$DistributionName


echo "---------------------------------------------"
echo "| Creating new infrastructure configuration |"
echo "---------------------------------------------"
aws imagebuilder create-infrastructure-configuration \
--name $ProjectName \
--description "ImageBuilder $ProjectName Infrastructure Configuration" \
--instance-types "m5.large" "m5.xlarge" \
--instance-profile-name $RoleName \
--security-group-ids $SecurityGroup \
--subnet-id $SubnetId \
--terminate-instance-on-failure \
--sns-topic-arn $SNSTopic


echo "-------------------------------"
echo "| Creating new image pipeline |"
echo "-------------------------------"
aws imagebuilder create-image-pipeline \
--name $ProjectName \
--description "Builds Amazon Linux 2 Images Pipeline" \
--image-recipe-arn arn:aws:imagebuilder:$Region:$AccountID:image-recipe/$ProjectName/$VersionId \
--infrastructure-configuration-arn arn:aws:imagebuilder:$Region:$AccountID:infrastructure-configuration/$DistributionName \
--distribution-configuration-arn arn:aws:imagebuilder:$Region:$AccountID:distribution-configuration/$DistributionName \
--image-tests-configuration imageTestsEnabled=true,timeoutMinutes=60 \
--schedule scheduleExpression="cron(0 2 1 * *)",pipelineExecutionStartCondition="EXPRESSION_MATCH_AND_DEPENDENCY_UPDATES_AVAILABLE" \
--status ENABLED


echo "---------------------------"
echo "| Starting Image Creation |"
echo "---------------------------"
aws imagebuilder start-image-pipeline-execution \
--image-pipeline-arn arn:aws:imagebuilder:$Region:$AccountID:image-pipeline/$DistributionName