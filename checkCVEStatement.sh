if [ $# -ne 1 ]
then
	echo "Insufficient arguments!"
	echo "Usage: $0 <CVE_ID>"
	exit 0
fi
if [[ $1 == "CVE"* ]]
then
	CVE=$1
else
	echo "Invalid argument! It must start with CVE."
	echo "Usage: $0 <CVE_ID>"
	exit 0
fi
echo $CVE
curl -s https://access.redhat.com/hydra/rest/securitydata/cve/$CVE | jq -rc '[ .threat_severity, .details[], .statement ]'
