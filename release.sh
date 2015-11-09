#!/bin/sh

set -e #exit on error
set -u #error on unset var usage

#wait for ok before continuing
pause() { read -p "Press Enter to continue..."; echo; }

#get repo and user names from current dir
repo=${PWD##*/}
cd ..; user=${PWD##*/}; cd $repo

#display script notes
echo "Running release script. Ctrl+C to quit at any time."
echo "User: $user"
echo "Repo: $repo"
echo "Working dir: $PWD"
pause

#check status and branch
git status
echo "Ensure status is ok and we're on the right branch"
pause

#ask for previous release
git tag
read -p "Previous release: " previous
#run git difftool
echo "Running difftool against $previous"
pause
git difftool $previous
echo "Done"
pause

#ask for change summary
read -p "Summary of changes: " changes
#ask for release version
read -p "Release version: " version
#ask if release is alpha or beta
read -p "[A]lpha or [B]eta? " prerelease
shopt -s nocasematch
case "$prerelease" in
  "A" ) version="${version}-alpha"; prerelease="true" ;;
  "B" ) version="${version}-beta" ; prerelease="true" ;;
  * )   prerelease="false" ;;
esac

#display obtained values
echo
echo "Version: $version"
echo "Changes: $changes"
pause

#make changes.txt
echo "New in $version: $changes" > tmp.txt
cat CHANGES.txt >> tmp.txt
mv tmp.txt CHANGES.txt
echo "Make edits to changes if needed"
pause
vim CHANGES.txt

#add to changelog.txt
echo "$version: $changes" > tmp.txt
cat CHANGELOG.txt >> tmp.txt
mv tmp.txt CHANGELOG.txt

#convert line endings
perl -p -e 's/[\r\n]+/\r\n/' < CHANGES.txt > tmp.txt
mv tmp.txt CHANGES.txt
perl -p -e 's/[\r\n]+/\r\n/' < CHANGELOG.txt > tmp.txt
mv tmp.txt CHANGELOG.txt
echo "Updated change logs EOL's"
pause

#display changes
git status
pause
git diff
pause
echo "Ready to release"
pause

#commit, tag, push
echo "Commit changes"
git c -am "releasing version $version"
pause
echo "Tag commit"
git tag $version
pause
echo "Push branch"
git push
pause
echo "Push tag"
git push --tags
pause

#get long description
read -p "Verbose description: " description

#send release POST
echo "Prepared to send release POST"
echo "User: $user"
echo "Repo: $repo"
echo "Prerelease: $prerelease"
echo "Tag: $version"
echo "Name: $changes"
echo "Description: $description"
pause
curl --user $user --data "{\"tag_name\":\"$version\",\"name\":\"$changes\",\"body\":\"$description\",\"prerelease\":$prerelease}" https://api.github.com/repos/$user/$repo/releases

#done
echo "Release complete!"
