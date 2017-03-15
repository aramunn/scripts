#!/bin/sh

set -e #exit on error
set -u #error on unset var usage

#install location
root="$APPDATA/NCSOFT/WildStar/addons"

#handle options
force=0
new=0
dir=""
while test $# -gt 0; do
  case "$1" in
    -h)
      echo "-l [pattern]: list addons in install dir filtering by pattern"
      echo "-f: skip install confirmation"
      echo "-n: create a new dir in install root"
      echo "-d: specify a custom install dir"
      exit 0
      ;;
    -l)
      shift
      if test $# -gt 0; then
        ls -l "$root" | grep -i "$1"
      else
        ls -l "$root"
      fi
      exit 0
      ;;
    -f)
      shift
      force=1
      ;;
    -n)
      shift
      new=1
      ;;
    -d)
      shift
      if test $# -gt 0; then
        dir="$1"
      else
        echo "specify a dir with -d"
        exit 1
      fi
      shift
      ;;
    *)
      break
      ;;
  esac
done

#set up pause func
pause() { read -p "Press Enter to continue..."; echo; }

#get addon name/dir if needed
if [ "$dir" == "" ]; then
  if [ ! -f "toc.xml" ]; then
    echo "Couldn't find toc.xml in current dir."
    exit
  fi
  name="$(perl -e '$s=`cat toc.xml`; $s=~m/Name="(.*?)"/; print "$1\n";')"
  dir="$root/$name"
else
  dir="$root/$dir"
fi

#make sure the install dir exists
if [ ! -d "$dir" ]; then
  if [ "$new" -eq 1 ]; then
    echo "[installing will create new dir]"
  else
    #try a different method
    dir="$root/${PWD##*/}"
    if [ ! -d "$dir" ]; then
      echo "Dir not found: $dir"
      exit
    fi
  fi
fi

#make robocopy opts
opts="//PURGE //E //NJS //NJH //NDL //XF *.yaml *.md *.luacheckrc *.gitignore //XD .git"

#double check dir is correct
if [ "$force" -eq 0 ]; then
  cmd //c robocopy . "$dir" $opts //L || echo
  read -p "Is this correct? (y/n): " ans
  if [ "$ans" != "y" ]; then
    exit
  fi
fi

#install
echo "installing..."
cmd //c robocopy . "$dir" $opts || echo

#done
echo "done"
