#!/bin/sh
OUTFILE="../intro".prg

./tools/convertRes
./tools/txt2scr -o scrolltext.asm scrolltext.txt

rm -f "$OUTFILE"

acme -v4 -f cbm -l labels.asm -o out.prg main.asm

./tools/sortLabels > memmap.txt

STARTADDR=$(grep "code_start" labels.asm | cut -d$ -f2)
exomizer3 sfx 0x$STARTADDR -x'dec 2023' -o "$OUTFILE" out.prg

rm -f out.prg
rm -f labels.asm

if [ -z "$1" ]
then
    vice -VICIIborders 0 -VICIIfilter 1 "$OUTFILE"
else
    vice -VICIIborders 2 -VICIIfilter 0 "$OUTFILE"
fi
