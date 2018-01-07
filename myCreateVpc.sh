#!/bin/bash
#
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
aws_vpc_cidr_block="172.22.0.0/16"
aws_subnet_cidr_block="172.22.1.0/24"

# constants for colored output
readonly NC='\033[0m' # No Color
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly CYAN='\033[0;36m'

# Defines a working area on the file system.
SCRATCH=/tmp/$$.scratch
 
### Functions

function cleanUp() {
  if [[ -d "$SCRATCH" ]]; then
    rm -r "$SCRATCH"
  fi
}

function validate_vpc_cidr_block() {
  local ip=${1}
  local result=1

  testformat=^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\/16$
  if [[ "${ip}" =~ ${testformat} ]]; then
    OIFS=$IFS
    IFS="./"
    ip=($ip)
    IFS=$OIFS
    [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
      && ${ip[2]} -eq 0 && ${ip[3]} -eq 0 ]]
    result=$?
  fi
  return ${result}
}

#TODO: move main if statements into syntax_usage() 
function syntax_usage() {
  local result="0"
  # Command syntax validation
  echo -e "nb d'args local = ${1}"                                          
  if [[ "${2}" -eq  "0" ]]; then                                         
#    echo -e "\n${NC}[${RED}SYNTAX ERROR${NC}]" \                       
#      "No arguments supplied\n"                                        
    result="1"
    #exit 1
  else
    if [[ "${2}" -gt "1" ]]; then                                          
#    echo -e "\n${NC}[${RED}SYNTAX ERROR${NC}]" \                       
#     "Too many arguments!\n"                                           
      result="2"
    #exit 2

    # Address IP validation                                              
    else
      if validate_vpc_cidr_block ${1}; then                                  
        result="10"                                                     
#    echo -e "\n[${GREEN}OK${NC}]" \                                    
#      "${CYAN}${1} ${NC}is a valid /16 CIDR Block\n"                   
      else
        result="3"                                                       
#    syntax_usage                                                       
#    echo -e "\n${NC}[${RED}SYNTAX ERROR${NC}]" \                       
#     "${CYAN}${1} ${NC}is not compliant to IPv4 format:" \             
#     "${CYAN}A.B.C.D/16${NC}\n"                                        
      fi
    fi
  fi

  echo -e "\nUsage:"
  echo -e "  ${CYAN}${__base} ${NC}<${YELLOW}vpc_cidr_block${NC}>\n"
  echo -e "Tips:"
  echo -e "  <${YELLOW}vpc_cidr_block${NC}> : " \
    "MUST have the following IPv4 CIDR format: ${YELLOW}A.B.C.D/16${NC}\n"
  echo -e "Example:"
  echo -e "  ${CYAN}${__base} ${YELLOW}172.22.0.0/16"

  echo -e "Result = ${result}"
  case ${result} in
    "1")
      echo -e "\n${NC}[${RED}SYNTAX ERROR${NC}]" \
        "No arguments supplied\n"
      exit 1                                        
      ;;
    "2")
      echo -e "\n${NC}[${RED}SYNTAX ERROR${NC}]" \
        "Too many arguments!\n"
      exit 2                                           
      ;;
    "3")
      echo -e "\n${NC}[${RED}SYNTAX ERROR${NC}]" \
        "${CYAN}${1} ${NC}is not compliant to IPv4 format:" \
        "${CYAN}A.B.C.D/16${NC}\n"
      exit 3
      ;;     
    "10")
      echo -e "\n[${GREEN}OK${NC}]" \
        "${CYAN}${1} ${NC}is a valid /16 CIDR Block\n"
      ;;                   
    *)
      error "Unexpected expression"
    ;;
  esac
}

# Pause
function my_pause() {
  read -p "Press enter to continue"
}

function aws_create_vpc() {
  # Starting the creation process
  echo -e "\nCreating VPC..."

  # create vpc
  cmd_output=$(aws ec2 create-vpc \
    --cidr-block "$aws_vpc_cidr_block" \
    --output json)
  VpcId=$(echo -e "${cmd_output}" | /usr/bin/jq '.Vpc.VpcId' | tr -d '"')

  # show result
  echo -e "\n[${GREEN}OK${NC}] VPC ${CYAN}'${VpcId}' ${NC}created."
}



### Main script starts here 

function main() {
  trap cleanUp EXIT
  mkdir "$SCRATCH"

#TODO: add test for $# equal to 0
  # Command syntax validation
  echo -e "all args = $@"
  echo -e "nb d'args = $# before"
 # echo -e "display arg1 = ${1}"                                          
  syntax_usage $@ $#
<<'END'  
if [[ "$#" -eq  "0" ]]; then
    syntax_usage
    echo -e "\n${NC}[${RED}SYNTAX ERROR${NC}]" \
      "No arguments supplied\n"
    exit 1
  fi
  
  if [[ "$#" -gt "1" ]]; then
    syntax_usage
    echo -e "\n${NC}[${RED}SYNTAX ERROR${NC}]" \
     "Too many arguments!\n"
    exit 2
  fi

  # Address IP validation
  if validate_vpc_cidr_block $1; then
    result='good';
    echo -e "\n[${GREEN}OK${NC}]" \
      "${CYAN}${1} ${NC}is a valid /16 CIDR Block\n"
  else
    result='bad'
    syntax_usage
    echo -e "\n${NC}[${RED}SYNTAX ERROR${NC}]" \
     "${CYAN}${1} ${NC}is not compliant to IPv4 format:" \
     "${CYAN}A.B.C.D/16${NC}\n"
  fi
END
  #echo -e "$1: " "${result}"

# name the vpc
# aws ec2 create-tags \
#   --resources "$VpcId" \
#   --tags Key=Name,Value="$aws_vpc_name"


  #echo -e "\n"


  # Sourced from http://www.alittlemadness.com/category/bash/
  # We succeeded, reset trap and clean up normally.
  trap - EXIT
  cleanUp
  exit 0
}
# Sourced from https://google.github.io/styleguide/shell.xml
#if ! do_something; then
#  err "Unable to do_something"
#  exit "${E_DID_NOTHING}"
#fi

# main call

main "$@"
