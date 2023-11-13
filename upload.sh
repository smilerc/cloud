#!/usr/bin/env bash

rake version:bump:minor

eval "$(ssh-agent -s)"
ssh-add  /Users/user/.ssh/id_smilerc

git add .
git commit -m $0
git push
