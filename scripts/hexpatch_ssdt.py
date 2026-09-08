#!/usr/bin/env python3
"""
hexpatch_ssdt.py — Hex-patch OEM Revision in all CB-01 SSDTs and compile patched ssdt04

This script:
    1. Copies all CB-01 SSDTs from the extracted XSDT directory
    2. Patches OEM Revision from 0x01 to 0x02 (required for kernel override)
    3. Recalculates ACPI checksums
    4. Decompiles, patches, and recompiles ssdt04 (NPCF table) with:
       - GPS GPSS guard removed from _DSM
       - GPS func0 support buffer byte4: 0x01 -> 0x11 (adds GETPPL bit)
       - GPS Case(0x24) GETPPL: returns {V1, PL1=45000mW, PL2=65000mW}
       - PSHAREPARAMS GPSP buffer enlarged 0x28 -> 0x2C (44 bytes)
       - PPMD status bit set in RETN
       - OEM Table ID unchanged (CB-01 for positional matching)

Usage:
    python3 hexpatch_ssdt.py ./xsdt/

Requirements:
    iasl (acpica-tools) for decompiling/recompiling ssdt04
"""

import os
import struct
import shutil
import subprocess
import sys


def patch_aml_header(aml_path):
    """Bump OEM Revision to 0x02 and fix checksum."""
    with open(aml_path, "r+b") as f:
        data = bytearray(f.read())

    if len(data) < 36:
        return False

    # OEM Revision is at offset 24-27 (little-endian u32)
    old_rev = struct.unpack_from("<I", data, 24)[0]
    if old_rev >= 0x02:
        return False  # already patched

    struct.pack_into("<I", data, 24, 0x00000002)

    # Recalculate ACPI checksum: sum of all bytes must be 0 mod 256
    data[9] = 0  # zero out existing checksum
    data[9] = (-(sum(data) % 256)) % 256

    with open(aml_path, "wb") as f:
        f.write(data)

    return True


def main():
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} ./xsdt/", file=sys.stderr)
        sys.exit(1)

    xsdt_dir = sys.argv[1]
    staging = "./cpio_build/kernel/firmware/acpi"
    os.makedirs(staging, exist_ok=True)

    # Step 1: Find all CB-01 SSDTs
    ssdt_files = sorted(
        [f for f in os.listdir(xsdt_dir) if f.lower().startswith("ssdt")],
        key=lambda x: int(re.sub(r"[^0-9]", "", x.split(".")[0]) or "0") if re.sub(r"[^0-9]", "", x.split(".")[0]) else 0
    )

    import re

    print(f"Found {len(ssdt_files)} SSDTs in {xsdt_dir}")

    # Step 2: Identify NPCF table (7946 bytes for LOQ 15IRX11)
    npcf_file = None
    npcf_idx = None
    for i, f in enumerate(ssdt_files):
        path = os.path.join(xsdt_dir, f)
        size = os.path.getsize(path)
        if size == 7946:
            npcf_file = f
            npcf_idx = i
            print(f"  NPCF table identified: {f} ({size} bytes, index {i})")
            break

    if npcf_file is None:
        print("ERROR: Could not identify NPCF table (expected 7946 bytes)", file=sys.stderr)
        print("Sizes:", [(f, os.path.getsize(os.path.join(xsdt_dir, f))) for f in ssdt_files])
        sys.exit(1)

    # Step 3: Copy and hex-patch all SSDTs + DSDT
    dsdt_src = os.path.join(xsdt_dir, "dsdt.dat")
    if os.path.exists(dsdt_src):
        shutil.copy2(dsdt_src, os.path.join(staging, "DSDT.aml"))
        print(f"  Copied DSDT.aml ({os.path.getsize(os.path.join(staging, 'DSDT.aml'))} bytes)")

    for i, f in enumerate(ssdt_files):
        src = os.path.join(xsdt_dir, f)
        dst_name = f"ssdt{i+1:02d}.aml"
        dst = os.path.join(staging, dst_name)
        shutil.copy2(src, dst)

        if i == npcf_idx:
            print(f"  {dst_name} = NPCF ({os.path.getsize(src)} bytes) — will be patched via iasl")
        else:
            patched = patch_aml_header(dst)
            if patched:
                print(f"  {dst_name} rev 0x01 -> 0x02")

    # Step 4: Patch ssdt04 (NPCF) via iasl
    npcf_dsl = os.path.join(staging, "ssdt04_patched.dsl")
    npcf_aml = os.path.join(staging, f"ssdt{npcf_idx+1:02d}.aml")

    if os.path.exists(npcf_dsl):
        print(f"\nCompiling patched NPCF SSDT from {npcf_dsl}...")
        result = subprocess.run(
            ["iasl", "-sa", npcf_dsl],
            capture_output=True, text=True, cwd=staging
        )
        print(result.stdout)
        if result.returncode != 0:
            print("ERROR: iasl compilation failed", file=sys.stderr)
            print(result.stderr, file=sys.stderr)
            sys.exit(1)

        # iasl outputs to ssdt04_patched.aml, rename to correct name
        compiled = os.path.join(staging, "ssdt04_patched.aml")
        if os.path.exists(compiled):
            shutil.move(compiled, npcf_aml)

        # Patch OEM Rev + checksum on the compiled NPCF
        patch_aml_header(npcf_aml)
        print(f"  NPCF SSDT compiled and patched: {os.path.getsize(npcf_aml)} bytes")
    else:
        print(f"WARNING: {npcf_dsl} not found — using unpatched NPCF", file=sys.stderr)

    # Step 5: Build CPIO
    cpio_path = "./dsdt.cpio"
    build_dir = "./cpio_build"
    print(f"\nBuilding CPIO: {cpio_path}")
    subprocess.run(
        ["find", "kernel", "-type", "f", "-name", "*.aml"],
        cwd=build_dir, stdout=subprocess.PIPE
    )

    result = subprocess.run(
        "find kernel -type f -name '*.aml' | cpio -o -H newc",
        shell=True, cwd=build_dir,
        stdout=open(cpio_path, "wb"),
        stderr=subprocess.PIPE
    )

    cpio_size = os.path.getsize(cpio_path)
    count_result = subprocess.run(
        ["cpio", "-t"],
        input=open(cpio_path, "rb").read(),
        shell=True, capture_output=True
    )
    file_count = len(count_result.stdout.decode().strip().split("\n"))
    print(f"  CPIO: {cpio_size:,} bytes, {file_count} entries")

    print(f"\nDeploy with:")
    print(f"  sudo cp /boot/dsdt.cpio /boot/dsdt.cpio.bak.$(date +%s)")
    print(f"  sudo cp {cpio_path} /boot/dsdt.cpio")


if __name__ == "__main__":
    main()
