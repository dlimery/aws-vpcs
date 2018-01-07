#!/bin/bash
#
# Script filename = "myCreate.sh"
# Create AWS Virtual Private Cloud (VPCs)

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
  echo -e "\n${GREEN}myCreateVpc" \
    "${NC}- bash script to create AWS VPCs -" \
    "${GREY}[pre-release-0.0.1]${NC}\n"
  echo -e "USAGE: ${CYAN}${__base} ${NC}<${YELLOW}vpc_cidr_block${NC}>\n"
  echo -e "DESCRIPTION:\n"
  echo -e "    myCreateVpc is a tool for creating AWS Virtual Private Cloud"
  echo -e "    (VPC) instances. Virtual Private Cloud is a virtual network"
  echo -e "    dedicated to an AWS account. It is logically isolated from"
  echo -e "    other virtual networks in the AWS Cloud. AWS resources can be"
  echo -e "    launched into VPCs, such as Amazon EC2 instances."
  echo -e "    myCreateVpc is a bash script which leverages AWS CLI commands."
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
      echo -e "\n${CYAN}myCreateVpc" \
        "${NC}- bash script to create AWS VPCs -" \
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

function aws_create_vpc() {
  local aws_vpc_cidr_block=${1}

  # Starting the creation process
  echo -e "\nCreating VPC..."

  # create vpc
  cmd_output=$(aws ec2 create-vpc \
    --cidr-block "${aws_vpc_cidr_block}" \
    --output json)
  VpcId=$(echo -e "${cmd_output}" | /usr/bin/jq '.Vpc.VpcId' | tr -d '"')

  # show result
  echo -e "\n[${GREEN}OK${NC}] VPC ${CYAN}'${VpcId}' ${NC}created."
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
  
  aws_create_vpc ${aws_vpc_cidr_block}

# name the vpc
# aws ec2 create-tags \
#   --resources "$VpcId" \
#   --tags Key=Name,Value="$aws_vpc_name"

}

main "$@"
