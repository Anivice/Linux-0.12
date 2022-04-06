#!/usr/bin/env bash
#                  1       2         3       4
# strip_bootsect file objcpy_exec dd_exec rm_exec

function is_dos_sector()
{
    if [ "$(file "$1")" = "$1: DOS/MBR boot sector" ]; then
        return 0
    else
        return 1
    fi
}

echo "Detecting file $1, objcpy=$2, dd=$3, rm=$4"

if ! is_dos_sector "$1"; then
  "$2" -O binary -R .note -R .comment "$1" "$1.tmp"
  "$3" if="$1.tmp" of="$1" bs=512 count=1
  "$4" "$1.tmp"
  echo "Strip finished"
else
  echo "File is already a DOS/MBR boot sector"
fi
