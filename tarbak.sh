#!/bin/bash
# Copyright © 2003,2014 Rob Leachman
# Please see the file COPYING in this distribution for license information
#
# 6/9/2014 - for git commit
# 2/9/2003 - works
#
# Check usage...
#  tarbak.sh
#     destination 
#        (defaults to /tmp)  - where the backup is stored
#     compression opiton
#        compress - create compressed tarball
#        defer - create compressed tarball, in separate process
#        null - nocompress, just create tarball
#
# Creates a tarball for each root subdirectory, except /dev, /mnt, /proc, /tmp,
# /lost+found, and also any subdirectories that contain a file '.tarbak_skip'
# (just touch one up to skip the subdirectory).
#
# Finally, will create an individual tarball for each subdirectory, except if
# the subdirectory contains a file '.tarbak_uses_subdirs' in which case
# each subordinate subdirectory will be backed up to a separate tarball (so
# /home can be saved as /home/rob and /home/quazar, etc).
#
#
# calls tarbak_fileset.sh to actually do the backup...

USAGE="$0 [dest|null (default /tmp)] [compress|defer|null (default nocompress)]"
if [ "$1x" = "-hx" ] ; then
  echo $USAGE
  exit 0
fi

OPT_DEST=$1
OPT_CMP=$2

DEST="/tmp"
if [ ! -z $OPT_DEST ] ; then
  DEST=$OPT_DEST
fi

if [ ! -d $DEST ] ; then
  echo "ERROR: subdirectory $DEST does not exist"
  echo $USAGE
  exit 1
fi

if [ "$2x" = "compressx" ] ; then
  COMPRESS="now"
else
  if [ "$2x" = "deferx" ] ; then
    COMPRESS="defer"
  else
    COMPRESS="none"
  fi
fi

SYSTEM=$(uname -a | cut -f 2 -d " ") 

echo -n "$0: using tar to backup $SYSTEM to $DEST"
if [ $COMPRESS = "now" ] ; then
  echo " with immediate compression..."
else
  if [ $COMPRESS = "defer" ] ; then
    echo "with deferred compression..."
  else
    echo " with no compression..."
  fi
fi

#put the date and system name in the log directory name (pid too, to be sure)
LOGDIR=$(date "+%Y-%m-%d.%H%M%S.$$")
LOGDIR=$(echo "$LOGDIR.$SYSTEM.logs")

if [ -d $DEST/$LOGDIR ] ; then
  echo "ABORT: log directory $LOGDIR exists!"
else
  mkdir $DEST/$LOGDIR
  if [ $? -ne 0 ] ; then
    echo "ABORT: cannot create log directory $LOGDIR"
  fi
fi

#for every root subdirectory, except this hardcoded "skip these" list...
for file in `ls / | grep -v -e $DEST -e "dev" -e "mnt" -e "proc" -e "tmp" -e "lost+found"` ; do
  if [ ! -e /$file/.tarbak_skip ] ; then
    if [ -e /$file/.tarbak_uses_subdirs ] ; then
    #  echo "  DEBUG: backup in pieces"
      ./tarbak_fileset.sh $file $DEST many $LOGDIR $COMPRESS
      RET=$?
    else
      #echo "  DEBUG: backup in one piece"
      ./tarbak_fileset.sh $file $DEST one $LOGDIR $COMPRESS
      RET=$?
    fi
    if [ $RET -ne 0 ] ; then
      echo "ABORT!"
      exit 1
    fi
# s/b optional, probably want to defer this in production?
# better: employ a daemon!
    if [ $COMPRESS = "now" ] ; then
      if [ -e $DEST/*.tar ] ; then
        gzip -9 $DEST/*.tar
        if [ $? -ne 0 ] ; then
          echo "ABORT: BAD GZIP!"
          exit 1
        fi
      fi
    fi
  fi
done
