#!/bin/bash
set -e

source dev-container-features-test-lib

check "grok is on PATH" command -v grok
check "agent is on PATH" command -v agent
check "grok --version succeeds" grok --version
check "grok binary is executable" test -x /usr/local/bin/grok
check "agent is a symlink to grok" test -L /usr/local/bin/agent

reportResults
