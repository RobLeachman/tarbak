#!/bin/bash
# Copyright ©2003,2014 Rob Leachman
# Please see the file COPYING in this distribution for license information
#
# 6/9/2014 - for git commit
# 2/9/2003 - works

#extra security
umask u=rw,go=

FILESET=$1
DEST=$2
PIECES=$3
LOGDIR=$4
COMPRESS=$5

SYSTEM=$(uname -a | cut -f 2 -d " ")

case "$PIECES" in
  one)
	ONELUMP=1
	;;
  many)
	ONELUMP=0
	;;
  *)
	echo "USAGE: $0 FILESET SPACE {one|many}"
        exit 0
	;;
esac

cd /$DEST
if [ $? -ne 0 ] ; then
  echo "ERROR: no such directory /$DEST"
  exit 1
fi

echo "TAR BACKUP BEGINS `date`">>/$DEST/$LOGDIR/$SYSTEM.log.$FILESET.stderr

RET=0
if [ $ONELUMP -eq 1 ] ; then
  TARBALL_FINAL="/$DEST/$SYSTEM.$FILESET.tar"
  if [ $COMPRESS = "defer" ] ; then
    TARBALL="/$DEST/$SYSTEM.$FILESET.tarbak"
  else
    TARBALL=$TARBALL_FINAL
  fi
  echo "Backing up $FILESET to $DEST/$FILESET.tar..."
  tar -vcf $TARBALL /$FILESET>>/$DEST/$LOGDIR/$SYSTEM.log.$FILESET.stdout 2>>/$DEST/$LOGDIR/$SYSTEM.log.$FILESET.stderr
  RET=$?
  if [ $COMPRESS = "defer" ] ; then
    mv $TARBALL $TARBALL_FINAL
  fi
else
  echo "Backing up $FILESET to $DEST/$FILESET.tar by subdir..."
  cd /$FILESET
  for file in `ls` ; do
    TARBALL_FINAL="/$DEST/$SYSTEM.$FILESET.$file.tar"
    if [ $COMPRESS = "defer" ] ; then
      TARBALL="/$DEST/$SYSTEM.$FILESET.$file.tarbak"
    else
      TARBALL=$TARBALL_FINAL
    fi
    tar -vcf $TARBALL /$FILESET/$file>>/$DEST/$LOGDIR/$SYSTEM.log.$FILESET.stdout 2>>/$DEST/$LOGDIR/$SYSTEM.log.$FILESET.stderr
    THISRET=$?
    if [ $RET -eq 0 ] ; then
      RET=$THISRET
    fi
    if [ $COMPRESS = "defer" ] ; then
      mv $TARBALL $TARBALL_FINAL
    fi
  done
fi
echo "TAR BACKUP ENDS `date`">>/$DEST/$LOGDIR/$SYSTEM.log.$FILESET.stderr
echo >> /$DEST/$LOGDIR/$SYSTEM.log.$FILESET.stderr

#make a master error log
grep -v -e "^$" -e "^TAR BACKUP" -e "^tar: Removing leading" /$DEST/$LOGDIR/$SYSTEM.log.$FILESET.stderr>>/$DEST/$LOGDIR/errors.$SYSTEM
#fix up the logs and we're done
mv /$DEST/$LOGDIR/$SYSTEM.log.$FILESET.stderr /$DEST/$LOGDIR/$SYSTEM.log.$FILESET
cat /$DEST/$LOGDIR/$SYSTEM.log.$FILESET.stdout >> /$DEST/$LOGDIR/$SYSTEM.log.$FILESET
rm /$DEST/$LOGDIR/$SYSTEM.log.$FILESET.stdout
exit $RET
