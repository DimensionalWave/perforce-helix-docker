#!/bin/bash
set -euo pipefail

init.sh && /usr/bin/tail -F $P4ROOT/logs/log
