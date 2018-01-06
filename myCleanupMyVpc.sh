#!/bin/bash
# delete-aws-my-vpc

# Constants for colored output
NC='\033[0m' # No Color
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'

res_vpcid=$(aws ec2 describe-vpcs \
		--filter Name=cidr,Values="172.22.0.0/16" \
		| jq '.Vpcs[0].VpcId' \
		| tr -d '"')

if [ ${res_vpcid} = "null" ]
then
	echo -e "\n${RED}[${NC}WARNING!${RED}] ${NC}No VPC to delete !!!"
else
	# Starting the deletion process
	echo -e "\nStarting deletion of VPC ${CYAN}'${res_vpcid}'"
	aws ec2 delete-vpc --vpc-id ${res_vpcid}
	# Print out successful deletion
	echo -e "\n${NC}[${GREEN}OK${NC}] VPC ${CYAN}'${res_vpcid}' ${NC}deleted!"
fi



echo -e "\n"
