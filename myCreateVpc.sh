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

arg1="${1:-}"

# Sourced from https://google.github.io/styleguide/shell.xml
#err() {
#  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $@" >&2
#}



# Defines a working area on the file system.
SCRATCH=/tmp/$$.scratch
 
function cleanUp() {
  if [[ -d "$SCRATCH" ]]; then
    rm -r "$SCRATCH"
    echo -e "rm -r "$SCRATCH""
  else
    echo -e "-d "$SCRATCH" is false"
    echo -e "exit not equal to 0"
  fi
}
 
trap cleanUp EXIT
mkdir "$SCRATCH"
 
# Actual work here, all temp files created under $SCRATCH.


# Importing valid_ip() function
. ../test/valid_ip.sh --source-only

# Pause
function myPause() {
  read -p "Press enter to continue"
}

# Command syntax validation
if [[ "$#" -eq  "0" ]]; then
  echo "No arguments supplied"
  exit 1
else
  echo "$1"
fi

myPause

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
readonly CYAN='\033[0;36m'

# Command arguments
echo -e "VPC CIDR Block is: $1"

# Address IP validation
if valid_ip $1; then
  stat='good';
else
  stat='bad'
fi

echo -e "$1: " "$stat"

# Starting the creation process
echo -e "\nCreating VPC..."

# create vpc
cmd_output=$(aws ec2 create-vpc \
  --cidr-block "$aws_vpc_cidr_block" \
  --output json)
VpcId=$(echo -e "${cmd_output}" | /usr/bin/jq '.Vpc.VpcId' | tr -d '"')

# show result
echo -e "\n[${GREEN}OK${NC}] VPC ${CYAN}'${VpcId}' ${NC}created."


# name the vpc
# aws ec2 create-tags \
#   --resources "$VpcId" \
#   --tags Key=Name,Value="$aws_vpc_name"


echo -e "\n"



# Sourced from http://www.alittlemadness.com/category/bash/
# We succeeded, reset trap and clean up normally.
trap - EXIT
echo "cleanup exit 0"
cleanUp
exit 0

# Sourced from https://google.github.io/styleguide/shell.xml
#if ! do_something; then
#  err "Unable to do_something"
#  exit "${E_DID_NOTHING}"
#fi


