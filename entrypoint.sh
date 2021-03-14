#!/bin/sh

set -e

bundle check || bundle install
bundle binstubs --path "$BUNDLE_BIN" --all

exec "$@"
