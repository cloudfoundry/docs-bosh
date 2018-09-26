#!/bin/bash

curl_path=snippets/bosh-cli/latest-version-curl-linux.md
supported_path=snippets/bosh-cli/latest-versions-table-supported.md
all_path=snippets/bosh-cli/latest-versions-table.md

fly -t production watch -j bosh:cli/build | grep -A1 '^sha1: ' > /tmp/found

version=$( grep /compiled-darwin /tmp/found | sed -E 's/.+bosh-cli-(.+)-darwin-amd64/\1/' | tr -d $'\r' )
darwin_sha1=$( grep -B1 /compiled-darwin /tmp/found | head -n1 | awk '{ print $2 }' | tr -d $'\r' )
linux_sha1=$( grep -B1 /compiled-linux /tmp/found | head -n1 | awk '{ print $2 }' | tr -d $'\r' )
windows_sha1=$( grep -B1 /compiled-windows /tmp/found | head -n1 | awk '{ print $2 }' | tr -d $'\r' )

cat > $curl_path <<EOF
curl -Lo ./bosh https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-$version-linux-amd64
EOF

cat > $supported_path <<EOF
| System         | Download                                                                                                         | Checksum (SHA1)                            |
| -------------- | ---------------------------------------------------------------------------------------------------------------- | ------------------------------------------ |
| Darwin / macOS | [bosh-cli-$version-darwin-amd64](https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-$version-darwin-amd64)           | \`$darwin_sha1\` |
| Linux          | [bosh-cli-$version-linux-amd64](https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-$version-linux-amd64)             | \`$linux_sha1\` |
EOF

cat > $all_path <<EOF
| System         | Download                                                                                                         | Checksum (SHA1)                            |
| -------------- | ---------------------------------------------------------------------------------------------------------------- | ------------------------------------------ |
| Darwin / macOS | [bosh-cli-$version-darwin-amd64](https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-$version-darwin-amd64)           | \`$darwin_sha1\` |
| Linux          | [bosh-cli-$version-linux-amd64](https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-$version-linux-amd64)             | \`$linux_sha1\` |
| Windows        | [bosh-cli-$version-windows-amd64.exe](https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-$version-windows-amd64.exe) | \`$windows_sha1\` |
EOF

git add $curl_path $supported_path $all_path
git ci -m "Update component references: bosh-cli/$version"
