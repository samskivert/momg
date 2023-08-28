#!/bin/sh

if [ -z "$1" ]; then
  echo "Usage: $0 gamename"
  exit 255
fi

echo "Uploading $1..."
scp -C $1.html samskivert.com:/export/samskivert/pages/play/2023/09
scp -C $1.js samskivert.com:/export/samskivert/pages/play/2023/09
