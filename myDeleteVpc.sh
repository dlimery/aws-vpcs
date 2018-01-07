#!/bin/bash
#
# Delete AWS Virtual Private Cloud (VPCs)

# Sourced from http://www.alittlemadness.com/category/bash/
# and from https://kvz.io/blog/2013/11/21/bash-best-practices/
set -o errexit
set -o pipefail
set -o nounset

# Enabling bash tracing
#set -o xtrace

# Set magic variables for current file & dir
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename ${__file} .sh)"
__root="$(cd "$(dirname "${__dir}")" && pwd)"

# misc variables
name="your VPC/network name"

# input variables
aws_region="eu-west-3"
aws_availability_zone="eu-west-3c"
aws_vpc_name="$name VPC"
aws_subnet_name="$name Subnet"
aws_instance_gateway_name="$name Gateway"
aws_route_table_name="$name Route Table"
aws_security_group_name="$name Security Group"
aws_subnet_cidr_block="172.22.1.0/24"


# constants for colored output
readonly NC='\033[0m' # No Color
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly CYAN='\033[0;36m'
readonly GREY='\033[0;90m'

### Functions

function my_pause() {
  read -p "Press enter to continue"
}

function validate_vpc_cidr_block() {
  local ip=${1}
  local return_code=1

  testformat=^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\/16$
  if [[ "${ip}" =~ ${testformat} ]]; then
    OIFS=$IFS
    IFS="./"
    ip=($ip)
    IFS=$OIFS
    [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
      && ${ip[2]} -eq 0 && ${ip[3]} -eq 0 ]]
    return_code=$?
  fi
  return ${return_code}
}

function display_usage() {
  local return_code=0

  echo -e "\t~\t~\t~\t~\t~\t~\t~"
  echo -e "\n${GREEN}myDeleteVpc" \
    "${NC}- bash script to delete AWS VPCs -" \
    "${GREY}[pre-release-0.0.1]${NC}\n"
  echo -e "USAGE: ${CYAN}${__base} ${NC}<${YELLOW}vpc_cidr_block${NC}>\n"
  echo -e "DESCRIPTION:\n"
  echo -e "    myDeleteVpc is a tool for deleting AWS Virtual Private Cloud"
  echo -e "    (VPC) instances. Virtual Private Cloud is a virtual network"
  echo -e "    dedicated to an AWS account. It is logically isolated from"
  echo -e "    other virtual networks in the AWS Cloud. AWS resources can be"
  echo -e "    launched into VPCs, such as Amazon EC2 instances."
  echo -e "    myDeleteVpc is a bash script which leverages AWS CLI commands."
  echo -e "    It accepts only one argument: an IPv4 CIDR block in /16\n"
  echo -e "    For more details see https://github.com/dlimery/aws-vpcs\n"
  echo -e "TIP:\n"
  echo -e "  <${YELLOW}vpc_cidr_block${NC}>" \
    "MUST have the following IPv4 CIDR format:" \
       "${YELLOW}A.B.${NC}0${YELLOW}.${NC}0${YELLOW}/16${NC}\n"
  echo -e "\texample: ${CYAN}${__base} ${YELLOW}172.22.0.0/16${NC}\n"
  return ${return_code}
}

function syntax_status() {
  local return_code=1
  if [[ "${1}" -gt "1" ]]; then
    return_code=2
    echo -e "\nOUTPUT:"
    echo -e "\n${NC}[${RED}SYNTAX ERROR${NC}]" \
        "Too many arguments!\n"
    display_usage
    exit 2
  else
    if validate_vpc_cidr_block ${2}; then
      return_code=0
      echo -e "\n${CYAN}myDeleteVpc" \
        "${NC}- bash script to delete AWS VPCs -" \
        "${GREY}[pre-release-0.0.1]${NC}\n"
      echo -e "\t~\t~\t~\t~\t~\t~\t~"
      echo -e "\nOUTPUT:"
      echo -e "\n[${GREEN}OK${NC}]" \
        "${CYAN}${2} ${NC}is a valid /16 CIDR Block\n"
    else
      return_code=3
      echo -e "\nOUTPUT:"
      echo -e "\n${NC}[${RED}SYNTAX ERROR${NC}]" \
        "${CYAN}${2} ${NC}is not compliant to IPv4 format:" \
        "${CYAN}A.B.0.0/16${NC}\n"
      display_usage
      exit 3
    fi
  fi
  return ${return_code}
}

function aws_delete_vpc() {
  res_vpcid=$(aws ec2 describe-vpcs \
      --filter Name=cidr,Values=${aws_vpc_cidr_block} \
    | jq '.Vpcs[0].VpcId' \
    | tr -d '"')

  if [ ${res_vpcid} = "null" ]; then
    echo -e "\n${RED}[${NC}WARNING!${RED}] ${NC}No VPC to delete !!!"
  else
    # Starting the deletion process
    echo -e "\nStarting deletion of VPC ${CYAN}'${res_vpcid}'"
    aws ec2 delete-vpc --vpc-id ${res_vpcid}
    # Print out successful deletion
    echo -e "\n${NC}[${GREEN}OK${NC}] VPC ${CYAN}'${res_vpcid}' ${NC}deleted!"
  fi
}



function main() {
  # Arguments validation tests
  if [[ "$#" -eq  "0" ]]; then
   echo -e "\n${NC}[${RED}SYNTAX ERROR${NC}]" \
      "No arguments supplied\n"
   display_usage
   exit 1
  fi
  if syntax_status $# $@; then
    aws_vpc_cidr_block=$@
  else
    exit 99
  fi

  #aws_delete_vpc ${aws_vpc_cidr_block}
}

main "$@"									
#fi

