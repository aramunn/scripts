#!/bin/sh

set -e #exit on error
set -u #error on unset var usage

force=0
for i in "$@"; do
  if [ "$i" == "-f" ]; then force=1; fi
done

#wait for ok before continuing
pause() { read -p "Press Enter to continue..."; echo; }

#get addon name/dir
if [ ! -f "toc.xml" ]; then
  echo "Couldn't find toc.xml in current dir."
  exit
fi
name="$(perl -e '$s=`cat toc.xml`; $s=~m/Name="(.*?)"/; print "$1\n";')"
dir="$APPDATA/NCSOFT/WildStar/addons/$name"
files=( *.{lua,xml} )

#double check dir is correct
if [ "$force" -eq 0 ]; then
  for file in ${files[@]}; do echo "$file"; done
  read -p "Installing the above files to $dir. Is this correct? (y/n): " ans
  if [ "$ans" != "y" ]; then
    exit
  fi
fi

#install
echo "installing..."
if [ ! -d "$dir" ]; then mkdir "$dir"; fi
for file in ${files[@]}; do cp "$file" "$dir"; done

#done
echo "done"
