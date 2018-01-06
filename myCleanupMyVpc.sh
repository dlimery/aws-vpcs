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


# Command syntax validation                                           
if [[ "$#" -eq  "0" ]]; then                                          
  echo "No arguments supplied"                                        
  exit 1                                                              
else                                                                  
  echo "$1"                                                           
fi                                                                    

# constants for colored output                                        
readonly NC='\033[0m' # No Color                                      
readonly RED='\033[0;31m'                                             
readonly GREEN='\033[0;32m'                                           
readonly CYAN='\033[0;36m'                                            

res_vpcid=$(aws ec2 describe-vpcs \
    --filter Name=cidr,Values="172.22.0.0/16" \
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
    
