#!/bin/bash

#####################
#
# Author : Alves José
# Date : 05/10/2017
# Description : upload files to aws s3 everyday
#
#
######################

/usr/bin/aws s3 cp /data/fcd/archive_day/FCD-CSV-Archive-`date +%Y-%m-%d`.tar s3://archives-fcd > /var/log/aws_s3_fcd_upload.log 2>&1
