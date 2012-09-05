#!/bin/sh

for target_dir in $@
do
  for f in `find "$target_dir" -type f 2>/dev/null`
  do
    sed -e '1,1{
      /^#!/d
    }' < $f > $f.tmp
    if ! cmp $f $f.tmp >/dev/null
    then
        mv -f $f.tmp $f
    else
        rm -f $f.tmp
    fi
  done
done
