#!/bin/bash

# This script is designed for Archivematica installations that have S3 configured as a storage space.
# It will do a fixity scan on each AIP individually, and after each AIP is scanned it will delete the AIP that was downloaded onto the local machine for scanning.
# The AIP in S3 will NOT be deleted! Only the temporary local copy that the fixity scanner downloaded.
# This should help smaller servers (e.g. 220GB) avoid hitting their capacity limit when there are a massive number of AIPs in S3 (e.g 10TB worth).
# The command "fixity scanall" doesn't automatically delete local downloaded copies in between scans, so this short script compensates for that.

# Force script to exit if certain commands fail
exit_on_error() {
    exit_code=$1
    last_command=${@:2}
    if [ $exit_code -ne 0 ]; then
        >&2 echo "\"${last_command}\" command failed with exit code ${exit_code}."
        exit $exit_code
    fi
}

# Load the variables defined in the fixity application
# https://www.archivematica.org/en/docs/storage-service-0.13/fixity/
source /etc/profile.d/fixity.sh
exit_on_error $? !!

# Go to the storage service directory where downloads are stored
cd /var/archivematica/storage_service/
exit_on_error $? !!

# Get every AIP ID as a variable called "aips", jq package is required: https://stedolan.github.io/jq/
aips=$(curl -H"Authorization: ApiKey $STORAGE_SERVICE_USER:$STORAGE_SERVICE_KEY" $STORAGE_SERVICE_URL/api/v2/file/ | jq '.objects[] | select(.status | contains("UPLOAD")) | .uuid' | tr -d '"')
exit_on_error $? !!

# Split the aips variable
aips=( $aips )

# Loop through each AIP
for i in "${aips[@]}"
do
   : 
	# Do a fixity scan on the AIP
	fixity scan $i 

	# Once the scan is complete, delete the temporary directory 
	if [ $( sudo find /var/archivematica/storage_service -type d -name "tmp??????" | wc -l ) != "0" ] ; then
		sudo rm -r tmp??????
	fi

done

exit 0
