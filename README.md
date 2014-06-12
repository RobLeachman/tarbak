# tarbak
A simple set of scripts to facilitate mothballing a system, 
or producing a pinpoint set of tarballs for backup/archive.

## Usage
tarbak.sh
  destination 
    (defaults to /tmp)  - where the backup is stored
  compression opiton
    compress - create compressed tarball
    defer - create compressed tarball, in separate process
    null - nocompress, just create tarball

Creates a tarball for each root subdirectory, except /dev, /mnt, /proc, /tmp,
/lost+found, and also any subdirectories that contain a file '.tarbak_skip'
(just touch one up to skip the subdirectory).

Finally, will create an individual tarball for each subdirectory, except if
the subdirectory contains a file '.tarbak_uses_subdirs' in which case
each subordinate subdirectory will be backed up to a separate tarball (so
/home can be saved as /home/rob and /home/quazar, etc).

###### License

This project and all associated files are 
Copyright © 2003,2014 Rob Leachman, released under GPL V3.
Please refer to the included file COPYING for specific
license information.
