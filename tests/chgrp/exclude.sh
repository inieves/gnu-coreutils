#!/bin/sh
# Make sure GNU chgrp works the same way as those of Solaris, HPUX, AIX
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
print_ver_ chgrp

require_membership_in_two_groups_

set _ $groups; shift
g1=$1
g2=$2

# when called on a single directory
# check --exclude-files excludes nothing
# and --exclude-directories excludes the directory

# create directory with group g1 and check
mkdir d                     || framework_failure_
chgrp $g1 d                 || framework_failure_
test $(stat --p=%g d) = $g1 || fail=1
# change group to g2 and check
chgrp $g2 d                 || framework_failure_
test $(stat --p=%g d) = $g2 || fail=1
# change group back to g1 with --exclude-directories
# and check unchanged
chgrp --exclude-directories $g1 d || fail=1
test $(stat --p=%g d) = $g2       || fail=1
# change group back to g1 with --exclude-files
# and check changed
chgrp --exclude-files $g1 d || fail=1
test $(stat --p=%g d) = $g1 || fail=1
# cleanup
rm -rf d || framework_failure_

# when called on a single file
# check --exclude-directories excludes nothing
# and --exclude-files excludes the file

# create file with group g1 and check
touch f                     || framework_failure_
chgrp $g1 f                 || framework_failure_
test $(stat --p=%g f) = $g1 || fail=1
# change group to g2 and check
chgrp $g2 f                 || framework_failure_
test $(stat --p=%g f) = $g2 || fail=1
# change group back to g1 with --exclude-files
# and check unchanged
chgrp --exclude-files $g1 f || fail=1
test $(stat --p=%g f) = $g2 || fail=1
# change group back to g1 with --exclude-directories
# and check changed
chgrp --exclude-directories $g1 f || fail=1
test $(stat --p=%g f) = $g1       || fail=1
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
# set group of parent directory to g1
# and check
chgrp $g1 d                 || framework_failure_
test $(stat --p=%g d) = $g1 || fail=1
# set group of child file to g1
# and check
chgrp $g1 d/f                 || framework_failure_
test $(stat --p=%g d/f) = $g1 || fail=1
# set group of child directory to g1
# and check
chgrp $g1 d/d                 || framework_failure_
test $(stat --p=%g d/d) = $g1 || fail=1
# recursively set all to g2 with --exclude-files
# and check file unchanged
chgrp -R --exclude-files $g2 d || fail=1
test $(stat --p=%g d) = $g2    || fail=1
test $(stat --p=%g d/f) = $g1  || fail=1
test $(stat --p=%g d/d) = $g2  || fail=1
# set child file to g2 and check
chgrp $g2 d/f                 || framework_failure_
test $(stat --p=%g d/f) = $g2 || framework_failure_
# recursively set all to g1 with --exclude-directories
# and check directory unchanged
chgrp -R --exclude-directories $g1 d || fail=1
test $(stat --p=%g d) = $g2          || fail=1
test $(stat --p=%g d/f) = $g1        || fail=1
test $(stat --p=%g d/d) = $g2        || fail=1
# set child file to g2 and check
chgrp $g2 d/f                 || framework_failure_
test $(stat --p=%g d/f) = $g2 || framework_failure_
# recursively set all to g1 with --exclude-files
# and --exclude-directories and check all unchanged
chgrp -R --exclude-files --exclude-directories $g1 d || fail=1
test $(stat --p=%g d) = $g2                          || fail=1
test $(stat --p=%g d/f) = $g2                        || fail=1
test $(stat --p=%g d/d) = $g2                        || fail=1
# cleanup
rm -rf d || framework_failure_

# when called on a directory with recursion (-R)
# and default of do not follow symlinks (-P)
# check --exclude-directories excludes directories only
# and --exclude-files excludes files only
# and combined they exclude everything
# and symlink referents are affected but not the symlink
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
# set structure to group g1
chgrp -R $g1 d1 || framework_failure_
chgrp $g1 f3    || framework_failure_
chgrp $g1 d4    || framework_failure_
chgrp $g1 d4/d5 || framework_failure_
chgrp $g1 d4/f6 || framework_failure_
chgrp $g1 d4/s7 || framework_failure_
chgrp $g1 d4/s8 || framework_failure_
# check groups set to g1
test $(stat --p=%g d1) = $g1    || framework_failure_
test $(stat --p=%g d1/f2) = $g1 || framework_failure_
test $(stat --p=%g f3) = $g1    || framework_failure_
test $(stat --p=%g d4) = $g1    || framework_failure_
test $(stat --p=%g d4/d5) = $g1 || framework_failure_
test $(stat --p=%g d4/f6) = $g1 || framework_failure_
test $(stat --p=%g d4/s7) = $g1 || framework_failure_
test $(stat --p=%g d4/s8) = $g1 || framework_failure_
# check --exclude-directories excludes directories only
chgrp -R -P --exclude-directories $g2 d4 || fail=1
test $(stat --p=%g d1) = $g1          || fail=1
test $(stat --p=%g d1/f2) = $g1       || fail=1
test $(stat --p=%g f3) = $g1          || fail=1
test $(stat --p=%g d4) = $g1          || fail=1
test $(stat --p=%g d4/d5) = $g1       || fail=1
test $(stat --p=%g d4/f6) = $g2       || fail=1
test $(stat --p=%g d4/s7) = $g2       || fail=1
test $(stat --p=%g d4/s8) = $g2       || fail=1
# reset
chgrp $g1 d4/f6                 || framework_failure_
chgrp -h $g1 d4/s7              || framework_failure_
chgrp -h $g1 d4/s8              || framework_failure_
test $(stat --p=%g d4/f6) = $g1 || framework_failure_
test $(stat --p=%g d4/s7) = $g1 || framework_failure_
test $(stat --p=%g d4/s8) = $g1 || framework_failure_
# check --exclude-files excludes files only
chgrp -R -P --exclude-files $g2 d4 || fail=1
test $(stat --p=%g d1) = $g1       || fail=1
test $(stat --p=%g d1/f2) = $g1    || fail=1
test $(stat --p=%g f3) = $g1       || fail=1
test $(stat --p=%g d4) = $g2       || fail=1
test $(stat --p=%g d4/d5) = $g2    || fail=1
test $(stat --p=%g d4/f6) = $g1    || fail=1
test $(stat --p=%g d4/s7) = $g1    || fail=1
test $(stat --p=%g d4/s8) = $g1    || fail=1
# reset
chgrp $g1 d4                    || framework_failure_
chgrp $g1 d4/d5                 || framework_failure_
test $(stat --p=%g d4) = $g1    || framework_failure_
test $(stat --p=%g d4/d5) = $g1 || framework_failure_
# check --exclude-directories and --exclude-files
# excludes everything
chgrp -R -P --exclude-directories --exclude-files $g2 d4 || fail=1
test $(stat --p=%g d1) = $g1                             || fail=1
test $(stat --p=%g d1/f2) = $g1                          || fail=1
test $(stat --p=%g f3) = $g1                             || fail=1
test $(stat --p=%g d4) = $g1                             || fail=1
test $(stat --p=%g d4/d5) = $g1                          || fail=1
test $(stat --p=%g d4/f6) = $g1                          || fail=1
test $(stat --p=%g d4/s7) = $g1                          || fail=1
test $(stat --p=%g d4/s8) = $g1                          || fail=1
# cleanup
rm -rf d1 || framework_failure_
rm f3     || framework_failure_
rm -rf d4 || framework_failure_

# when called on a directory with recursion (-R)
# and do follow symlinks (-L)
# check --exclude-directories excludes directories only
# and --exclude-files excludes files only
# and combined they exclude everything
# and symlink referents are affected but not the symlink
# and symlinks are traversed
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
# set structure to group g1
chgrp -R $g1 d1 || framework_failure_
chgrp $g1 f3    || framework_failure_
chgrp $g1 d4    || framework_failure_
chgrp $g1 d4/d5 || framework_failure_
chgrp $g1 d4/f6 || framework_failure_
chgrp $g1 d4/s7 || framework_failure_
chgrp $g1 d4/s8 || framework_failure_
# check groups set to g1
test $(stat --p=%g d1) = $g1    || framework_failure_
test $(stat --p=%g d1/f2) = $g1 || framework_failure_
test $(stat --p=%g f3) = $g1    || framework_failure_
test $(stat --p=%g d4) = $g1    || framework_failure_
test $(stat --p=%g d4/d5) = $g1 || framework_failure_
test $(stat --p=%g d4/f6) = $g1 || framework_failure_
test $(stat --p=%g d4/s7) = $g1 || framework_failure_
test $(stat --p=%g d4/s8) = $g1 || framework_failure_
# check --exclude-directories excludes directories only
chgrp -R -L --exclude-directories $g2 d4 || fail=1
test $(stat --p=%g d1) = $g1             || fail=1
test $(stat --p=%g d1/f2) = $g2          || fail=1
test $(stat --p=%g f3) = $g2             || fail=1
test $(stat --p=%g d4) = $g1             || fail=1
test $(stat --p=%g d4/d5) = $g1          || fail=1
test $(stat --p=%g d4/f6) = $g2          || fail=1
test $(stat --p=%g d4/s7) = $g1          || fail=1
test $(stat --p=%g d4/s8) = $g1          || fail=1
# reset
chgrp $g1 d1/f2                 || framework_failure_
chgrp $g1 f3                    || framework_failure_
chgrp $g1 d4/f6                 || framework_failure_
test $(stat --p=%g d1/f2) = $g1 || framework_failure_
test $(stat --p=%g f3) = $g1    || framework_failure_
test $(stat --p=%g d4/f6) = $g1 || framework_failure_
# check --exclude-files excludes files only
chgrp -R -L --exclude-files $g2 d4 || fail=1
test $(stat --p=%g d1) = $g2       || fail=1
test $(stat --p=%g d1/f2) = $g1    || fail=1
test $(stat --p=%g f3) = $g1       || fail=1
test $(stat --p=%g d4) = $g2       || fail=1
test $(stat --p=%g d4/d5) = $g2    || fail=1
test $(stat --p=%g d4/f6) = $g1    || fail=1
test $(stat --p=%g d4/s7) = $g1    || fail=1
test $(stat --p=%g d4/s8) = $g1    || fail=1
# reset
chgrp $g1 d1                    || framework_failure_
chgrp $g1 d4                    || framework_failure_
chgrp $g1 d4/d5                 || framework_failure_
test $(stat --p=%g d1) = $g1    || framework_failure_
test $(stat --p=%g d4) = $g1    || framework_failure_
test $(stat --p=%g d4/d5) = $g1 || framework_failure_
# check --exclude-directories and --exclude-files
# excludes everything
chgrp -R -L --exclude-directories --exclude-files $g2 d4 || fail=1
test $(stat --p=%g d1) = $g1                             || fail=1
test $(stat --p=%g d1/f2) = $g1                          || fail=1
test $(stat --p=%g f3) = $g1                             || fail=1
test $(stat --p=%g d4) = $g1                             || fail=1
test $(stat --p=%g d4/d5) = $g1                          || fail=1
test $(stat --p=%g d4/f6) = $g1                          || fail=1
test $(stat --p=%g d4/s7) = $g1                          || fail=1
test $(stat --p=%g d4/s8) = $g1                          || fail=1
# cleanup
rm -rf d1 || framework_failure_
rm f3     || framework_failure_
rm -rf d4 || framework_failure_

Exit $fail
