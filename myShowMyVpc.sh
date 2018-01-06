aws ec2 describe-vpcs \
	--filter Name=cidr,Values="172.22.0.0/16" \
	| jq '.Vpcs[0].VpcId' \
	| tr -d '"'
