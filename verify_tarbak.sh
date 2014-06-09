#!/bin/sh
# Copyright © 2003,2014 Rob Leachman
# Please see the file COPYING in this distribution for license information
#
# 6/9/2014 - for git commit
# 2/9/2003 - works

cd /mnttmp
filelist=$(ls *.tar.gz)
date>verify.filelist
for file in $filelist ; do
  echo $file>>verify.filelist
  gzip -dc $file | tar -tf ->>verify.list 2>>verify.errors
done
date>>verify.filelist
