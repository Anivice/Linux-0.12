#!/usr/bin/env bash
#               1       2         3       4
# strip_setup file objcpy_exec dd_exec rm_exec
echo "Detecting file $1, objcpy=$2, dd=$3, rm=$4"

"$2" -O binary -R .note -R .comment "$1" "$1.tmp"
"$3" if="$1.tmp" of="$1.bin" bs=512 count=3 2> /dev/null > /dev/null
"$4" "$1.tmp"
echo "Strip finished"
