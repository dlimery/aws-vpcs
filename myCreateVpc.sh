#!/bin/bash
# create-aws-vpc

# input variables
awsRegion="eu-west-3"
awsAvailabilityZone="eu-east-3c"
awsVpcName="$name VPC"
awsSubnetName="$name Subnet"
awsInstanceGatewayName="$name Gateway"
awsRouteTableName="$name Route Table"
awsSecurityGroupName="$name Security Group"
awsVpcCidrBlock="172.22.0.0/16"
awsSubNetCidrBlock="172.22.1.0/24"

# misc variables
name="your VPC/network name"
port22CidrBlock="0.0.0.0/0"
destinationCidrBlock="0.0.0.0/0"

# constants for colored output
NC='\033[0m' # No Color
RED='\033[0;31m'
CYAN='\033[0;36m'

echo -e "Creating VPC..."

# create vpc
cmd_output=$(aws ec2 create-vpc \
        	--cidr-block "$awsVpcCidrBlock" \
        	--output json)
VpcId=$(echo -e "${cmd_output}" | /usr/bin/jq '.Vpc.VpcId' | tr -d '"')

# show result
echo -e "VPC with ${CYAN}VpcID = \"${VpcId}\" ${NC}created."

# name the vpc
# aws ec2 create-tags \
#        --resources "$VpcId" \
#        --tags Key=Name,Value="$awsVpcName"

