#!/bin/bash
# Copyright © 2003,2014 Rob Leachman
# Please see the file COPYING in this distribution for license information
#
# 6/9/2014 - for git commit
# 2/9/2003 - works

cd /mnttmp
while [ 1=1 ] ; do
  tarfiles=$(ls *.tar)
  if [ ! -z "$tarfiles" ] ; then
    for file in $tarfiles ; do
      echo "Compressing $file"
      gzip -9 $file
    done
  else
    echo "Nothing to do! I should count how many times that occurs, and quit after I see there's nothing to do like 10x or something!"
    echo "Even better, something could *tell* me when to quit!"
  fi
  echo "I will look for more work again in 10"
  sleep 10
done
