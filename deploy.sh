#!/bin/bash
set -e

#MODS=/d/factorio/factorio-local/mods
MODS=/d/x/factorio-local/mods

title=$(cat info.json | grep '"name"' | sed -e 's/.*://' -e 's/[", ]//g')
ver=$(cat info.json | grep '"version"' | sed -e 's/.*://' -e 's/[", ]//g')

mkdir -p /tmp/$title
rsync -av --delete . /tmp/$title/ \
      --exclude deploy.sh \
      --exclude '__*' \
      --exclude '*__copy*' \
      --exclude '.git' \

cd /tmp
zip -r ${title}_$ver.zip $title
mv ${title}_$ver.zip $MODS/
