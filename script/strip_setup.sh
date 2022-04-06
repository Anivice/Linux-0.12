#!/usr/bin/env bash
#               1       2         3       4
# strip_setup file objcpy_exec dd_exec rm_exec

function is_elf_80386_fresh()
{
    if [ "$(file "$1")" = "$1: ELF 32-bit LSB executable, Intel 80386, version 1 (SYSV), statically linked, not stripped" ]; then
        return 0
    else
        return 1
    fi
}

echo "Detecting file $1, objcpy=$2, dd=$3, rm=$4"

if is_elf_80386_fresh "$1"; then
  "$2" -O binary -R .note -R .comment "$1" "$1.tmp"
  "$3" if="$1.tmp" of="$1" bs=512 count=3
  "$4" "$1.tmp"
  echo "Strip finished"
else
  echo "File is already stripped"
fi
