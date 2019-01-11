This script is intended for use with Archivematica, when Amazon S3 is set as the storage space.

[Artefactual's fixity checker tool](https://www.archivematica.org/en/docs/storage-service-0.13/fixity/) works by downloading AIPs from S3 to a temporary directory in /var/archivematica/storage_service before it begins scanning for corruption. 

If there are 10TB worth of AIPs in S3, and only 220GB available on the server, then this may create a problem. The command "fixity scanall" will attempt to download 10TB worth of AIPs to a 220GB server!

This script acts similarly to fixity scanall, but it downloads, scans and then deletes each AIP *one at a time*. There will never be more than one copy of an S3 AIP in /var/archivematica/storage_service at a time while this script is running.

It does not delete AIPs from S3, it only deletes locally saved temporary copies!

### Installation ###

Make sure that [Artefactual's fixity checker tool](https://www.archivematica.org/en/docs/storage-service-0.13/fixity/) is installed.

Install the package jq.

```bash
sudo apt-get install jq
```

You should now be able to run the script from the command line.
