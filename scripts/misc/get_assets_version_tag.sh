#!/bin/bash

assets_path="$1"
assets_version="$2"

if [ "$assets_path" == "demo" ]; then
    assets_version="kbe-demo-$assets_version"
fi

echo "$assets_version"
