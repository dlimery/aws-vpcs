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

aws ec2 describe-vpcs \
    --filter Name=cidr,Values="172.22.0.0/16" \
  | jq '.Vpcs[0].VpcId' \
  | tr -d '"'

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
