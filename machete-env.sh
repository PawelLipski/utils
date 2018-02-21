#!/usr/bin/env bash

newb() {
	git checkout -b $1
}

cmt() {
	f=${1}-${2}.txt
	touch $f
	git add $f
	git commit -m "$*"
}

cd ~/machete-blog
rm -fr /tmp/_git
mv .git /tmp/_git
git init

newb root
	cmt Root
newb develop
	cmt Develop commit
newb adjust-reads-prec
	cmt Adjust JSON Reads precision
	cmt 1st round of fixes
newb block-cancel-order
	cmt Implement blocking order cancellation
newb change-table
	cmt Alter the existing tables
newb drop-location-type
	cmt Drop location type from models

git checkout develop
newb edit-margin-not-allowed
	cmt Disallow editing margin
newb full-load-gatling
	cmt Implement Gatling full load scenario

git checkout develop
newb grep-errors-script
	cmt Add script for grepping the errors

git checkout root
newb master
	cmt Master commit
newb hotfix/remove-trigger
	cmt '[HOTFIX]' Remove the trigger

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
