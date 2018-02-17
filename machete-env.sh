#!/usr/bin/env bash

newb() {
    f=${1/\//-}.txt
    touch $f
    git add $f
    git checkout -b $1
    git commit -m $1
}

cd ~/machete-blog
rm -fr /tmp/_git
mv .git /tmp/_git
git init

newb root
newb develop
newb adjust-reads-prec
newb block-cancel-order
git checkout develop
newb change-table
newb drop-location-type

git checkout develop
newb edit-margin-not-allowed
newb full-load-gatling

git checkout develop
newb grep-errors-script

git checkout root
newb master
newb hotfix/remove-trigger

cat >.git/machete <<EOF
develop
    adjust-reads-prec
        block-cancel-order
            change-table
                drop-location-type
    edit-margin-not-allowed
        full-load-gatling
    grep-errors-script
master
    hotfix/remove-trigger
EOF
git machete status -l
