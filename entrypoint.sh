#!/bin/sh
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

echo "###################"
echo "Tagging Parameters"
echo "###################"
echo "flag_branch: <<${INPUT_FLAG_BRANCH}>>"
echo "message: <<${INPUT_MESSAGE}>>"
echo "prev_tag: <<${INPUT_PREV_TAG}>>"
echo "update_odoo_module_version: <<${INPUT_UPDATE_ODOO_MODULE_VERSION}>>"
echo "###################"

echo "Setting up git machine..."
git_setup

echo "Updating repository tags..."
git fetch origin --tags

last_tag=""
if [ "${INPUT_FLAG_BRANCH}" = true ];then
    branch=$(git rev-parse --abbrev-ref HEAD)
    echo "branch: <<${branch}>>";

    last_tag=`git describe --tags $(git rev-list --tags) --always|egrep "${INPUT_PREV_TAG}${branch}\.[0-9]*\.[0-9]*$"|sort -V -r|head -n 1`
    echo "Last tag: <<${last_tag}>>";
else
    last_tag=`git describe --tags $(git rev-list --tags --max-count=1)`
    echo "Last tag: <<${last_tag}>>";
fi


if [ -z "${last_tag}" ];then
    if [ "${INPUT_FLAG_BRANCH}" != false ];then
        last_tag="${INPUT_PREV_TAG}${branch}.1.0";
    else
        last_tag="${INPUT_PREV_TAG}0.1.0";
    fi
    echo "Default Last tag: <<${last_tag}>>";
fi

next_tag="${last_tag%.*}.$((${last_tag##*.}+1))"
echo "Next tag: <<${next_tag}>>";


if [ "${INPUT_UPDATE_ODOO_MODULE_VERSION}" = true ];then
    echo "Upload tag for Odoo module...";
    git checkout "${GITHUB_SHA}";

    for file in '__openerp__.py' '__manifest__.py';do
        if [ ! -f "${file}" ];then
            continue
        fi

        echo "Updating file version ${file}..."
        new_version=`echo ${next_tag}|sed "s,^v\(.*\),\1,g"`

        sed -i "s,\(\s*.version.*:\).*,\1 \"${new_version}\"\,,g" ${file}
        git add ${file}
    done

    git commit -m "${INPUT_MESSAGE}"
    tag_commit=`git rev-parse --verify HEAD`
    echo "Forcing tag update..."
    git tag ${next_tag}
    echo "Forcing tag push..."
    git push --tags
else
    echo "Forcing tag update..."
    git tag -a ${next_tag} -m "${INPUT_MESSAGE}" "${GITHUB_SHA}" -f
    echo "Forcing tag push..."
    git push --tags -f
fi

