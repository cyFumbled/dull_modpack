#!/bin/bash

usage () {
    printf '%s' "
generate_toml -v arg

    -h: print help

    -v: degree of version change (major, minor, patch)
"
}
version_degree="bum"
while getopts "hv:" flag; do
    case "${flag}" in
        h) usage ; exit 0;;
        v) echo "flag -v (version_degree): $OPTARG" ; version_degree="$OPTARG" ;;
    esac
done

if [ "$#" -eq 0 ]; then
    usage
    exit 1
fi

version="$(grep version thunderstore.toml | cut -d '"' -f 2)"

if [ "$version_degree" = "major" ]; then 
    version="$(("${version:0:1}" + 1)).0.0"
elif [ "$version_degree" = "minor" ]; then
    version="${version:0:1}.$(( ${version:2:1} + 1 )).0"
elif [ "$version_degree" = "patch" ]; then
    version="${version:0:4}$(( ${version:4} + 1 ))"
else
    usage
    exit 1
fi

printf '%s%s%s%s%s' '[config]
schemaVersion = "0.0.1"

[package]
namespace = "neurotic"
name = "dull_pack"
versionNumber = "' \
\
"$version" \
\
'"
description = "dull and rather unfocused as of now. wip!"
websiteUrl = "https://github.com/cyFumbled/dull_modpack"
containsNsfwContent = false

[package.dependencies]
' \
\
"$(sed -e 's/"//1' -e 's/,//1' -e 's/-/ = "/2' ".dependencies.txt" | sort)"\
\
\
'

[build]
icon = "./icon.png"
readme = "./README.md"
outdir = "./build"

[publish]
repository = "https://thunderstore.io"
communities = ["lethal-company"]
[publish.categories]
lethal-company = ["modpacks","audio","bepinex","serverside","monsters","moons","cosmetics","asset-replacements","weather","bug-fixes","performance","tweaks-and-quality-of-life"]
' > new.toml

diff thunderstore.toml new.toml