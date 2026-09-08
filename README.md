# LOQ NPCF — 65W Dynamic Boost Unlock for Lenovo LOQ 15IRX11 (RTX 5050)

**GPU:** RTX 5050 Laptop (10DE:2D98, GB207M)  
**OEM:** Lenovo LOQ Essential 15IRX11 (83SC)  
**Driver:** nvidia-open 610.57.04  
**Kernel:** CachyOS 7.2.x (CONFIG_ACPI_TABLE_UPGRADE=y required)

## Problem

The stock BIOS ACPI table (SSDT with NPCF device at `\_SB.NPCF`) returns **zeroed power budget fields** in the NVPCF DSM func 0x02 (GET_DYNAMIC_PARAMS) response:

| Field | Stock Value | Meaning |
|-------|------------|---------|
| TGPA (TGP AC) | 0x0000 (0W) | No GPU power target |
| TGPD (TGP DC) | 0x0000 (0W) | No DC power target |
| TPPA (TPP AC) | 0x0000 (0W) | No total platform power |
| MAGA (Max AC) | 0x0000 (0W) | No max offset |

The nvidia driver's `client_resource.c` constructs the PMO (Power Management Object) because bit 0 of func 0x00 IS set, but **Dynamic Boost cannot compute any offsets** with zeroed budget fields. `nvidia-powerd` falls back to VBIOS default **35W** — GPU never boosts to its 65W max.

## Root Cause

`nv-acpi.c:785-793` hardcodes the NVPCF DSM call to pathname `\\_SB.NPCF._DSM`. The driver's namespace walk (`nv-acpi.c:361`) discovers `\_SB.NPCF` successfully. The problem is not discovery — it's that the **SBIOS returns zeroed data** in the response buffers.

## Fix

ACPI SSDT override via initrd using `CONFIG_ACPI_TABLE_UPGRADE`. The override SSDT defines `\_SB.NPCF` with correct power budget values in all DSM subfunctions.

**Key values in the override:**

| Func | Return | Details |
|------|--------|---------|
| 0x00 (GET_SUPPORTED) | `Buffer(4){0x07,0x01,0x00,0x00}` | bit 0=PMO present, bit 8=DC power limits |
| 0x01 (GET_DYNAMIC_PARAMS 1X) | 14 bytes | Standard 1X dynamic params with valid checksum |
| 0x02 (GET_DYNAMIC_PARAMS 2X) | 49 bytes | Header v0x25, TGPA=65W, TPPA=135W, MAGA=120W |
| 0x08 (GET_DC_SYSTEM_POWER_LIMITS) | 22 bytes | DC power limits for battery mode |

**Applied via initrd:** Uncompressed `newc` cpio containing `kernel/firmware/acpi/DSDT.aml` (patched DSDT with embedded NPCF device) loaded before the real initramfs via Limine `module_path`.

## Results

| Metric | Stock BIOS | With Override |
|--------|-----------|---------------|
| Current Power Limit | 35W | **65W** |
| Dynamic Boost | Not active | **Active** |
| Synthetic load (cuda-matmul) | ~35W | **65W sustained** |
| Gaming (Genshin Impact avg) | ~45W | **53W** (with CPU undervolt) |
| AE_ALREADY_EXISTS | 242 | **0** |

## Files

- `npcf-loq.dsl` — SSDT override source (ASL)
- `npcf-loq.aml` — Compiled AML (302 bytes)
- `NVPCF-MATCH-SPEC.md` — Full driver analysis and buffer validation rules
- `RECOVERY-AND-TEST.md` — Recovery procedure and test results

## How to Apply

**This is a reference implementation.** The exact DSDT patching is machine-specific.

1. Extract stock DSDT: `sudo acpidump -o acpi.dat && acpixtract -a acpi.dat dsdt.dat`
2. Decompile: `iasl -d dsdt.dat`
3. Patch: Remove `External(_SB_.NPCF)` and insert NPCF device definition inside `Scope(_SB)`
4. Recompile: `iasl dsdt_patched.dsl`
5. Build cpio: `echo kernel/firmware/acpi/DSDT.aml | cpio -o -H newc > /boot/dsdt.cpio`
6. Add as first initrd in bootloader config (before real initramfs)

See [NVIDIA issue #XXX](https://github.com/NVIDIA/open-gpu-kernel-modules/issues/XXX) for driver-side discussion.

## Why SSDT Override Alone Doesn't Work

All 22 CB-01 SSDTs share `(SSDT, LENOVO, CB-01)` identity. The kernel's `acpi_table_initrd_override()` matches by `(Signature + OEM_ID + OEM_Table_ID)` and processes the first match positionally. With 22 identical tuples, the wrong table gets replaced. Additionally, the kernel silently skips if `firmware_rev >= initrd_rev`.

**DSDT override** works because there's only one DSDT — no ambiguity.

## References

- [NVIDIA open-gpu-kernel-modules](https://github.com/NVIDIA/open-gpu-kernel-modules)
- [Acer Nitro ANV15-52 NVPCF fix](https://github.com/brad2130-del/Acer-Nitro-ANV15-52-5050-gaming-configuration) (similar pattern)
- [kxj0258's Mechrevo Blackwell NPCF report](https://github.com/NVIDIA/open-gpu-kernel-modules/issues/1162)
- Kernel docs: `Documentation/admin-guide/acpi/dsdt-override.rst`

## License

GPL-3.0 — see [LICENSE](LICENSE).
