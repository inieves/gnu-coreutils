#!/bin/sh
# Make sure GNU chmod works the same way as those of Solaris, HPUX, AIX
# on directories with the setgid bit set.  Also, check that the GNU octal
# notations work.

# Copyright (C) 2001-2018 Free Software Foundation, Inc.

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

. "${srcdir=.}/tests/init.sh"; path_prepend_ ./src
print_ver_ chmod

require_membership_in_two_groups_

umask 0

# when called on a single directory
# check --exclude-files excludes nothing
# and --exclude-directories excludes the directory

# create directory with mode 755 and check
mkdir d                 || framework_failure_
chmod 755 d             || framework_failure_
chmod -c 755 d > empty  || framework_failure_
compare /dev/null empty || framework_failure_
# change mode to 700 and check
chmod 700 d             || framework_failure_
chmod -c 700 d > empty  || framework_failure_
compare /dev/null empty || framework_failure_
# change mode back to 755 with --exclude-directories
# and check unchanged
chmod --exclude-directories 755 d || fail=1
chmod -c 700 d > empty            || framework_failure_
compare /dev/null empty           || fail=1
# change mode back to 755 with --exclude-directories
# and --exclude-files and check unchanged
chmod --exclude-directories --exclude-files 755 d || fail=1
chmod -c 700 d > empty                            || framework_failure_
compare /dev/null empty                           || fail=1
# change mode back to 755 with --exclude-files
# and check changed
chmod --exclude-files 755 d || fail=1
chmod -c 755 d > empty      || framework_failure_
compare /dev/null empty     || fail=1
# cleanup
rm -rf d || framework_failure_

# when called on a single file
# check --exclude-directories excludes nothing
# and --exclude-files excludes the file

# create file with mode 755 and check
touch f                 || framework_failure_
chmod 755 f             || framework_failure_
chmod -c 755 f > empty  || framework_failure_
compare /dev/null empty || framework_failure_
# change mode to 700 and ckeck
chmod 700 f             || framework_failure_
chmod -c 700 f > empty  || framework_failure_
compare /dev/null empty || framework_failure_
# change mode back to 755 with --exclude-files
# and check unchanged
chmod --exclude-files 755 f || fail=1
chmod -c 700 f > empty      || framework_failure_
compare /dev/null empty     || fail=1
# change mode back to 755 with --exclude-files
# and --exclude-directories and check unchanged
chmod --exclude-files --exclude-directories 755 f || fail=1
chmod -c 700 f > empty                            || framework_failure_
compare /dev/null empty                           || fail=1
# change mode back to 755 with --exclude-directories
# and check changed
chmod --exclude-directories 755 f || fail=1
chmod -c 755 f > empty            || framework_failure_
compare /dev/null empty           || fail=1
# cleanup
rm -f f || framework_failure_

# when called on a directory with recursion (-R)
# check --exclude-directories excludes directories only
# and --exclude-files excludes files only
# and combined they exclude everything

# create directory with a child file
# and child directory within
mkdir d   || framework_failure_
touch d/f || framework_failure_
mkdir d/d || framework_failure_
# set permissions of parent directory to 755
# and check
chmod 755 d             || framework_failure_
chmod -c 755 d > empty  || framework_failure_
compare /dev/null empty || framework_failure_
# set permissions of child file to 755
# and check
chmod 755 d/f            || framework_failure_
chmod -c 755 d/f > empty || framework_failure_
compare /dev/null empty  || framework_failure_
# set permissions of child directory to 755
# and check
chmod 755 d/d            || framework_failure_
chmod -c 755 d/d > empty || framework_failure_
compare /dev/null empty  || framework_failure_
# recursively set all to 744 with --exclude-files
# and check file unchanged
chmod -R --exclude-files 744 d || fail=1
chmod -c 744 d > empty         || framework_failure_
compare /dev/null empty        || fail=1
chmod -c 755 d/f > empty       || framework_failure_
compare /dev/null empty        || fail=1
chmod -c 744 d/d > empty       || framework_failure_
compare /dev/null empty        || fail=1
# recursively set all to 733 with --exclude-directories
# and check directory unchanged
chmod -R --exclude-directories 733 d || fail=1
chmod -c 744 d > empty               || framework_failure_
compare /dev/null empty              || fail=1
chmod -c 733 d/f > empty             || framework_failure_
compare /dev/null empty              || fail=1
chmod -c 744 d/d > empty             || framework_failure_
compare /dev/null empty              || fail=1
# recursively set all to 722 with --exclude-files
# and --exclude-directories and check all unchanged
chmod -R --exclude-files --exclude-directories 722 d || fail=1
chmod -c 744 d > empty                               || framework_failure_
compare /dev/null empty                              || fail=1
chmod -c 733 d/f > empty                             || framework_failure_
compare /dev/null empty                              || fail=1
chmod -c 744 d/d > empty                             || framework_failure_
compare /dev/null empty                              || fail=1
# cleanup
rm -rf d || framework_failure_

# when called on a directory with recursion (-R)
# check --exclude-directories excludes directories only
# and --exclude-files excludes files only
# and combined they exclude everything
# and symlink are ignored
# and symlinks are not traversed
# using structure:
#
#   d1
#     f2
#   f3
#   d4
#     d5
#     f6
#     s7 -> d1
#     s8 -> f3

# create structure
mkdir d1          || framework_failure_
touch d1/f2       || framework_failure_
touch f3          || framework_failure_
mkdir d4          || framework_failure_
mkdir d4/d5       || framework_failure_
touch d4/f6       || framework_failure_
ln -s ../d1 d4/s7 || framework_failure_
ln -s ../f3 d4/s8 || framework_failure_
# set all to 755
chmod -R 755 d1 || framework_failure_
chmod 755 f3    || framework_failure_
chmod -R 755 d4 || framework_failure_
# check all 755
chmod -c 755 d1 > empty    || framework_failure_
compare /dev/null empty    || framework_failure_
chmod -c 755 d1/f2 > empty || framework_failure_
compare /dev/null empty    || framework_failure_
chmod -c 755 f3 > empty    || framework_failure_
compare /dev/null empty    || framework_failure_
chmod -c 755 d4 > empty    || framework_failure_
compare /dev/null empty    || framework_failure_
chmod -c 755 d4/d5 > empty || framework_failure_
compare /dev/null empty    || framework_failure_
chmod -c 755 d4/f6 > empty || framework_failure_
compare /dev/null empty    || framework_failure_
# check --exclude-directories excludes directories only
chmod -R --exclude-directories 744 d4 || fail=1
chmod -c 755 d1 > empty               || framework_failure_
compare /dev/null empty               || fail=1
chmod -c 755 d1/f2 > empty            || framework_failure_
compare /dev/null empty               || fail=1
chmod -c 755 f3 > empty               || framework_failure_
compare /dev/null empty               || fail=1
chmod -c 755 d4 > empty               || framework_failure_
compare /dev/null empty               || fail=1
chmod -c 755 d4/d5 > empty            || framework_failure_
compare /dev/null empty               || fail=1
chmod -c 744 d4/f6 > empty            || framework_failure_
compare /dev/null empty               || fail=1
# reset
chmod 755 d4/f6            || framework_failure_
chmod -c 755 d4/f6 > empty || framework_failure_
compare /dev/null empty    || framework_failure_
# check --exclude-files excludes files only
chmod -R --exclude-files 744 d4 || fail=1
chmod -c 755 d1 > empty               || framework_failure_
compare /dev/null empty               || fail=1
chmod -c 755 d1/f2 > empty            || framework_failure_
compare /dev/null empty               || fail=1
chmod -c 755 f3 > empty               || framework_failure_
compare /dev/null empty               || fail=1
chmod -c 744 d4 > empty               || framework_failure_
compare /dev/null empty               || fail=1
chmod -c 744 d4/d5 > empty            || framework_failure_
compare /dev/null empty               || fail=1
chmod -c 755 d4/f6 > empty            || framework_failure_
compare /dev/null empty               || fail=1
# reset
chmod 755 d4               || framework_failure_
chmod 755 d4/d5            || framework_failure_
chmod -c 755 d4 > empty    || framework_failure_
compare /dev/null empty    || framework_failure_
chmod -c 755 d4/d5 > empty || framework_failure_
compare /dev/null empty    || framework_failure_
# check --exclude-directories and --exclude-files
# excludes everything
chmod -R --exclude-directories --exclude-files 744 d4 || fail=1
chmod -c 755 d1 > empty                               || framework_failure_
compare /dev/null empty                               || fail=1
chmod -c 755 d1/f2 > empty                            || framework_failure_
compare /dev/null empty                               || fail=1
chmod -c 755 f3 > empty                               || framework_failure_
compare /dev/null empty                               || fail=1
chmod -c 755 d4 > empty                               || framework_failure_
compare /dev/null empty                               || fail=1
chmod -c 755 d4/d5 > empty                            || framework_failure_
compare /dev/null empty                               || fail=1
chmod -c 755 d4/f6 > empty                            || framework_failure_
compare /dev/null empty                               || fail=1
# cleanup
rm -rf d1 || framework_failure_
rm f3     || framework_failure_
rm -rf d4 || framework_failure_

# when called on symlink to a directory
# and a symlink to a file
# check --exclude-files excludes the target file only
# and --exclude-directories excludes the target directory only
# and --exclude-files and --exclude-directories excludes both

# creat directory and file and links
mkdir d       || framework_failure_
touch f       || framework_failure_
ln -s d linkd || framework_failure_
ln -s f linkf || framework_failure_
# set permissions to 755
chmod 755 d || framework_failure_
chmod 755 f || framework_failure_
# check --exclude-directories excludes directories
chmod --exclude-directories 744 linkd || fail=1
chmod --exclude-directories 744 linkf || fail=1
chmod -c 755 d > empty                || framework_failure_
compare /dev/null empty               || fail=1
chmod -c 744 f > empty                || framework_failure_
compare /dev/null empty               || fail=1
# reset
chmod 755 f             || framework_failure_
chmod -c 755 f > empty  || framework_failure_
compare /dev/null empty || fail=1
# check --exclude-files excludes files
chmod --exclude-files 744 linkd || fail=1
chmod --exclude-files 744 linkf || fail=1
chmod -c 744 d > empty          || framework_failure_
compare /dev/null empty         || fail=1
chmod -c 755 f > empty          || framework_failure_
compare /dev/null empty         || fail=1
# reset
chmod 755 d             || framework_failure_
chmod -c 755 d > empty  || framework_failure_
compare /dev/null empty || fail=1
# check --exclude-directories and --exclude-files
# excludes directories and files
chmod --exclude-directories --exclude-files 744 linkd || fail=1
chmod --exclude-directories --exclude-files 744 linkf || fail=1
chmod -c 755 d > empty          || framework_failure_
compare /dev/null empty         || fail=1
chmod -c 755 f > empty          || framework_failure_
compare /dev/null empty         || fail=1
# cleanup
rm linkd || framework_failure_
rm linkf || framework_failure_
rm -rf d || framework_failure_
rm f     || framework_failure_

Exit $fail
