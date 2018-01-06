#!/bin/bash
# delete-aws-my-vpc

# Constants for colored output
NC='\033[0m' # No Color
RED='\033[0;31m'
CYAN='\033[0;36m'

res_vpcid=$(aws ec2 describe-vpcs \
		--filter Name=cidr,Values="172.22.0.0/16" \
		| jq '.Vpcs[0].VpcId' \
		| tr -d '"')

if [ ${res_vpcid} = "null" ]
then
	echo -e "\n${RED}[${NC}WARNING!${RED}] ${NC}No VPC to delete !!!\n"
else
	# Starting the deletion process
	echo -e "Starting deletion of VPC with ${CYAN}VpcID = ${res_vpcid}"
	aws ec2 delete-vpc --vpc-id ${res_vpcid}
	# Print out successful deletion
	echo -e "VPC with ${CYAN}VpcID = ${res_vpcid} ${NC}deleted!"
fi
