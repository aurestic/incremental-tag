#!/bin/bash
set -eu

# Set up .netrc file with GitHub credentials
git_setup ( ) {
  echo $GITHUB_ACTOR;
  echo $GITHUB_TOKEN;
  cat <<- EOF > $HOME/.netrc
        machine github.com
        login $GITHUB_ACTOR
        password $GITHUB_TOKEN
        machine api.github.com
        login $GITHUB_ACTOR
        password $GITHUB_TOKEN
EOF
    chmod 600 $HOME/.netrc

    git config --global user.email "actions@github.com"
    git config --global user.name "Latest tag GitHub Action"
}

echo "Setting up git machine..."
git_setup

echo "Getting last tag..."
last_tag=`git describe --tags $(git rev-list --tags --max-count=1)`
echo "Last tag is ${last_tag}"

echo "Getting next tag..."
next_tag="${last_tag%.*}.$((${last_tag##*.}+1))"
echo "Next tag will be ${next_tag}"

echo "Forcing tag update..."
git tag -a ${next_tag} "${GITHUB_SHA}" -f

echo "Forcing tag push..."
git push --tags -f
