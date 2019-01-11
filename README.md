This script is intended for use with Archivematica, when Amazon S3 is set as the storage space.

To run a fixity check, the storage service needs to first download the AIP from S3 before it is scanned. This AIP is downloaded to /var/archivematica/storage_service.

If there are 10TB worth of AIPs in S3, and only 220GB available on the server, then this may create a problem. The command "fixity scanall" will attempt to download 10TB worth of AIPs to a 220GB server!

This script acts similarly to fixity scanall, but it deletes each AIP from /var/archivematica/storage_servive after it is scanned rather than leaving them in place to accumulate.

Artefactual's fixity application must first be installed for this to work: https://www.archivematica.org/en/docs/storage-service-0.13/fixity/

The package 'jq' is also required to parse the JSON returned by a REST request: https://stedolan.github.io/jq/
