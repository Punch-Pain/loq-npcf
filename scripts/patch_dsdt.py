#!/usr/bin/env python3
"""
patch_dsdt.py — Embed NPCF device into Lenovo LOQ DSDT

This script patches the stock Lenovo LOQ 15IRX11 DSDT to include an NPCF
device at Scope(\_SB) with the correct NVPCF DSM payloads for 65W Dynamic Boost.

Usage:
    python3 patch_dsdt.py input.dsl output.dsl

What it does:
    1. Removes the External(_SB_.NPCF, ...) declaration (causes AE_ALREADY_EXISTS
       when our device is loaded)
    2. Adds External declarations for GPSS and NPCS FieldUnitObj
    3. Inserts a complete Device(NPCF) block after "Scope (_SB) {" with:
       - _HID = "NVDA0820", _UID = "NPCF", _STA = 0x0F
       - _INI: sets GPSS=1, NPCS=1 via CondRefOf
       - _DSM: UUID check 36b49710-2483-11e7-9598-0800200c9a66
       - func0: Buffer(4){0x07,0x01,0x00,0x00} (bits 0,1,2 + bit8=DC support)
       - func1: 14-byte config buffer, two's complement checksum = 0xAB
       - func2: 49-byte dynamic params (header v0x25, TGPA=0x0208/65W, TPPA=0x0438/135W, MAGA=0x03C0/120W)
       - func8: 22-byte DC system power limits

Requirements:
    iasl (acpica-tools) to compile the patched DSL
"""

import sys
import re


def main():
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} input.dsl output.dsl", file=sys.stderr)
        sys.exit(1)

    input_path = sys.argv[1]
    output_path = sys.argv[2]

    with open(input_path, "r") as f:
        lines = f.readlines()

    result = []
    removed_external = False
    scope_sb_inserted = False
    inserted_scope_sb = False

    # NPCF device block to insert after "Scope (_SB) {"
    npcf_block = """\
            External (_SB_.PC00.PEG1.PEGP.GPSS, FieldUnitObj)
            External (_SB_.PC00.PEG1.PEGP.NPCS, FieldUnitObj)
            Device (NPCF)
            {
                Name (_HID, "NVDA0820")
                Name (_UID, "NPCF")
                Method (_STA, 0, NotSerialized)
                {
                    Return (0x0F)
                }

                Method (_INI, 0, NotSerialized)
                {
                    If (CondRefOf (\_SB.PC00.PEG1.PEGP.GPSS))
                    {
                        ^^PC00.PEG1.PEGP.GPSS = One
                    }

                    If (CondRefOf (\_SB.PC00.PEG1.PEGP.NPCS))
                    {
                        ^^PC00.PEG1.PEGP.NPCS = One
                    }
                }

                Method (_DSM, 4, Serialized)
                {
                    If ((Arg0 == ToUUID ("36b49710-2483-11e7-9598-0800200c9a66")))
                    {
                        If ((Arg1 == 0x0200))
                        {
                            Switch (ToInteger (Arg2))
                            {
                                Case (Zero)
                                {
                                    Return (Buffer (0x04)
                                    {
                                         0x07, 0x01, 0x00, 0x00
                                    })
                                }
                                Case (One)
                                {
                                    Return (Buffer (0x0E)
                                    {
                                        /* 00 */ 0x20, 0x03, 0x01, 0x00,
                                        /* 04 */ 0x25, 0x04, 0x05, 0x01,
                                        /* 08 */ 0x01, 0x01, 0x00, 0x00,
                                        /* 0C */ 0x00, 0xAB
                                    })
                                }
                                Case (0x02)
                                {
                                    Return (Buffer (0x31)
                                    {
                                        /* Header: version=0x25, headerSize=5, commonSize=0x10, entrySize=0x1C, entryCount=1 */
                                        /* 00 */ 0x25, 0x05, 0x10, 0x1C, 0x01,
                                        /* common: CTGP_AC_OFFSET=0x0208 (TGPA=65W) */
                                        /* 05 */ 0x08, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                                        /* 0D */ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                                        /* entry[0]: */
                                        /* 15 */ 0x68, 0x01, 0x00, 0x00,   /* param0: TGPA=0x0168 (360 units) */
                                        /* 19 */ 0xC0, 0x03, 0x00, 0x00,   /* param1: TPPA=0x03C0 (960 units) */
                                        /* 1D */ 0x88, 0xFF, 0x00, 0x00,   /* param2: MAGA=0xFF88 (-120 units) */
                                        /* 21 */ 0x00, 0x00, 0x00, 0x00,
                                        /* 25 */ 0x00, 0x00, 0x00, 0x00,
                                        /* 29 */ 0x00, 0x00, 0x00, 0x00,
                                        /* 2D */ 0x00, 0x00, 0x00, 0x00
                                    })
                                }
                                Case (0x08)
                                {
                                    Return (Buffer (0x16)
                                    {
                                        /* DC system power limits */
                                        /* 00 */ 0x20, 0x04, 0x09, 0x02,
                                        /* 04 */ 0x64, 0xA4, 0x1F, 0x00,
                                        /* 08 */ 0x00, 0x00, 0x00, 0x00,
                                        /* 0C */ 0x00, 0x14, 0x34, 0x21,
                                        /* 10 */ 0x00, 0x00, 0x00, 0x00,
                                        /* 14 */ 0x00, 0x00
                                    })
                                }
                            }
                        }
                    }

                    Return (Buffer (One)
                    {
                         0x00
                    })
                }
            }
"""

    for i, line in enumerate(lines):
        # 1. Remove External NPCF declaration
        if not removed_external and re.match(r'\s*External\s+\(_SB_\.NPCF', line):
            removed_external = True
            continue

        result.append(line)

        # 2. Insert NPCF block after "Scope (_SB) {" line
        if not inserted_scope_sb:
            stripped = line.strip()
            if stripped.startswith("Scope (\\_SB)") and "{" in stripped:
                result.append(npcf_block)
                inserted_scope_sb = True

    if not inserted_scope_sb:
        print("ERROR: Could not find 'Scope (\\_SB) {' in DSDT", file=sys.stderr)
        sys.exit(1)

    if not removed_external:
        print("WARNING: External(_SB_.NPCF,...) not found — may need manual removal", file=sys.stderr)

    with open(output_path, "w") as f:
        f.writelines(result)

    print(f"Patched DSDT written to {output_path}")
    print(f"  - Removed External NPCF: {'yes' if removed_external else 'no'}")
    print(f"  - Inserted NPCF device: {'yes' if inserted_scope_sb else 'no'}")
    print(f"Compile with: iasl -tc {output_path}")


if __name__ == "__main__":
    main()
