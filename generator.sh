#!/bin/bash

d=~/workspace/src/github.com/dpb587-pivotal/bosh-json-schema

(
  echo "---"
  echo "schema: true"
  echo "---"
  echo

  echo "# AWS Cloud Properties"
  echo

  go run $d/docsifier.go '{"path":"az"}' < $d/v0/cpi/aws/v0/az.json
  go run $d/docsifier.go '{"path":"network"}' < $d/v0/cpi/aws/v0/network.json
  go run $d/docsifier.go '{"path":"vm"}' < $d/v0/cpi/aws/v0/vm.json
  go run $d/docsifier.go '{"path":"disk"}' < $d/v0/cpi/aws/v0/disk.json
  go run $d/docsifier.go '{"path":"config"}' < $d/v0/cpi/aws/v0/config.json
) > content/aws-cpi.md

(
  echo "---"
  echo "schema: true"
  echo "---"
  echo

  echo "# Cloud Config"
  echo

  go run $d/docsifier.go < $d/v0/director/v0/cloud-config.json
) > content/cloud-config.md

(
  echo "---"
  echo "schema: true"
  echo "---"
  echo

  echo "# Runtime Config"
  echo

  go run $d/docsifier.go < $d/v0/director/v0/runtime-config.json
) > content/runtime-config.md

(
  echo "---"
  echo "schema: true"
  echo "---"
  echo

  echo "# Deployment Manifest"
  echo

  go run $d/docsifier.go < $d/v0/director/v0/deployment-v2.json
) > content/manifest-v2.md
