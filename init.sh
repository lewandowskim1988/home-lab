#!/usr/bin/env bash
set -euo pipefail

helm template argocd \
  -f argocd/values-skynet.yaml argo/argo-cd | kubectl --server-side=true -n argocd apply -f-
