This script is intended for use with Archivematica, when Amazon S3 is set as the storage space.

To run a fixity check, the storage service needs to first download an AIP from S3 before it can begin scanning. This AIP is then downloaded to /var/archivematica/storage_service.

If there are 10TB worth of AIPs in S3, and only 220GB available on the server, then this may create a problem. The command "fixity scanall" will attempt to download 10TB worth of AIPs to a 220GB server!

This script acts similarly to fixity scanall, but it scans and then deletes each AIP *one at a time* from /var/archivematica/storage_servive.

### Installation ###

Make sure that [Artefactual's fixity application](https://www.archivematica.org/en/docs/storage-service-0.13/fixity/) is installed.

Install the package jq.

```bash
sudo apt-get install jq
```

You should now be able to run the script from the command line.
