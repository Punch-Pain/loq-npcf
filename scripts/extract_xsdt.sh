#!/usr/bin/env bash
# extract_xsdt.sh — Extract all ACPI tables from the running system
# Output: ./xsdt/ directory with DSDT.dat, SSDT1.dat ... SSDTn.dat
#
# Requires: acpidump, acpixtract (from acpica-tools)

set -euo pipefail

OUTDIR="./xsdt"
mkdir -p "$OUTDIR"

echo "[1/2] Dumping ACPI tables..."
sudo acpidump -b -o /tmp/acpi_dump.bin

echo "[2/2] Extracting tables..."
acpixtract -a /tmp/acpi_dump.bin -d "$OUTDIR"

echo "Done. Tables in $OUTDIR:"
ls -lhS "$OUTDIR"/*.dat 2>/dev/null || ls -lhS "$OUTDIR"/*.AML 2>/dev/null
echo ""
echo "Next: identify the NPCF table (7946 bytes for LOQ 15IRX11):"
echo "  for f in $OUTDIR/ssdt*.dat; do echo \$(stat -c%s \$f) \$f; done | sort -n"
