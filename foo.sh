#!/bin/sh

set -e

cd "$(git rev-parse --show-cdup)"

# Find all the objects that are in packs:

for p in .git/objects/pack/pack-*.idx
do
    git show-index < $p | cut -f 2 -d ' '
done

# And now find all loose objects:

find .git/objects/ | egrep '[0-9a-f]{38}' | \
  sed -r 's,^.*([0-9a-f][0-9a-f])/([0-9a-f]{38}),\1\2,'
