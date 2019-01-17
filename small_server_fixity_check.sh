#!/bin/bash

# This script is designed for Archivematica installations that have S3 configured as a storage space.
# It will do a fixity scan on each AIP individually, and after each AIP is scanned it will delete the AIP that was downloaded onto the local machine for scanning.
# The AIP in S3 will NOT be deleted! Only the temporary local copy that the fixity scanner downloaded.
# This should help smaller servers (e.g. 220GB) avoid hitting their capacity limit when there are a massive number of AIPs in S3 (e.g 10TB worth).
# The command "fixity scanall" doesn't automatically delete local downloaded copies in between scans, so this short script compensates for that.

if [ $( whoami ) != "archivematica" ] ; then
	echo ERROR: You need to run this script as the user 'archivematica'
	exit 1
fi

if [ ! -f /usr/local/bin/fixity ]; then
	echo ERROR: Make sure that you have installed fixity!
	exit 1
fi

if [ -z $( command -v jq ) ] ; then
	echo ERROR: Install the jq package before continuing: https://stedolan.github.io/jq/ 
	exit 1
fi

# Get every AIP ID as a variable called "aips", jq package is required: https://stedolan.github.io/jq/
aips=$(curl -H"Authorization: ApiKey $STORAGE_SERVICE_USER:$STORAGE_SERVICE_KEY" $STORAGE_SERVICE_URL/api/v2/file/ | jq '.objects[] | select(.status | contains("UPLOAD")) | .uuid' | tr -d '"')

# Split the aips variable
aips=( $aips )

# Loop through each AIP
for i in "${aips[@]}"
do
   : 
	# Get existing tmp AIPs as a variable, $EXISTING_TMP
	EXISTING_TMP=$(find /var/archivematica/storage_service -type d -name "tmp??????")

	# In parallel with the fixity scan (below), delete existing AIPs 
	[  -z "$EXISTING_TMP" ] && echo "No tmp dirs to delete!" || rm -r $EXISTING_TMP & 
	
	# Do a fixity scan on the AIP, in parallel with the deletion
	/usr/local/bin/fixity scan $i &&

	# Run commands in foreground
	fg	
done

# Delete last remaining tmp directory, don't throw an error message if there isn't one.
rm -r /var/archivematica/storage_service/tmp?????? 2> /dev/null

exit 0
