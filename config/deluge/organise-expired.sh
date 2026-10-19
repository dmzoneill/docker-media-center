#!/bin/bash
exec "$(dirname -- "$0")/reorganise-matching.sh" 'EXPIRED\|UNREGISTERED'
