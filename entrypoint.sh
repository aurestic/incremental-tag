#!/bin/bash
set -eu

# Set up .netrc file with GitHub credentials
git_setup ( ) {
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
    git config --global user.name "Incremental tag GitHub Action"
}

echo "Setting up git machine..."
git_setup

echo "Updating repository tags..."
git fetch --tags

last_tag=""
if [[ $INPUT_FLAG_BRANCH ]];then
    echo "Getting version branch"
    branch=$(git rev-parse --abbrev-ref HEAD)
    echo "Branch ${branch}"

    echo "Getting last tag..."
    last_tag=`git describe --tags $(git rev-list --tags) --always|egrep "${INPUT_PREV_TAG}${branch}\.[0-9]\.[0-9]$"|head -n 1`
    echo "Last tag is ${last_tag}"
else
    echo "Getting last tag..."
    last_tag=`git describe --tags $(git rev-list --tags --max-count=1)`
    echo "Last tag is ${last_tag}"
fi


if [[ "${last_tag}" == "" ]];then
    last_tag="${INPUT_PREV_TAG}${branch}.0.0";
fi

echo "Getting next tag..."
next_tag="${last_tag%.*}.$((${last_tag##*.}+1))"
echo "Next tag will be ${next_tag}"

if [[ ${INPUT_UPDATE_ODOO_MODULE_VERSION} ]];then
    echo "GITHUB_SHA: ${GITHUB_SHA}"
    git checkout "${GITHUB_SHA}";

    for file in ('__openerp__.py' '__manifest__.py');do
        echo "Updating file version ${file}..."
        new_version=`echo ${next_tag}|sed "s,^v\(.*\),\1,g"`

        echo "new_version: ${new_version}"
        sed -i "s,\(\s*\"version\":\).*,\1 \"${new_version}\"\,,g" ${file}
        git add ${file}
    done
    git commit -m "${INPUT_MESSAGE}"

    tag_commit=`git rev-parse --verify HEAD`
    echo "tag_commit: ${tag_commit}"
    git tag -a ${next_tag} -m "${INPUT_MESSAGE}" "${tag_commit}" -f

else
    echo "Forcing tag update..."
    git tag -a ${next_tag} -m "${INPUT_MESSAGE}" "${GITHUB_SHA}" -f
fi

echo "Forcing tag push..."
git push --tags -f
