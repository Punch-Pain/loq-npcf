# LOQ-NPCF: 65W Dynamic Boost Unlock for Lenovo LOQ 15IRX11 (RTX 5050)

> [!WARNING]
> This project modifies ACPI tables that are loaded at boot time. Incorrect patches can
> cause kernel panics, boot failures, or permanent hardware damage.
>
> **Use at your own risk.** Always keep a backup of your original `/boot/dsdt.cpio` and
> `/boot/limine.conf` before making changes. If you choose to use this project and damage
> your system, it is your responsibility, not mine.

ACPI override that unlocks the full 65W TGP+CTGP+PPAB power budget on the Lenovo LOQ
Essential 15IRX11 83SC by patching the NVPCF (NVIDIA Power Control Firmware) and GPS
(GPU Power Steering) ACPI tables via Linux initrd table override.

**Result: 50W → 65W power limit, +16% sustained GPU power in games, touchpad preserved.**

## TL;DR

The Lenovo LOQ ships with an RTX 5050 that supports up to 65W (50W TGP + 15W PPAB),
but the BIOS only exposes 50W. The NVPCF ACPI table controls power boost parameters,
and the GPS table handles platform power management. Both tables have bugs and missing
features. This project patches them via the Linux kernel's `CONFIG_ACPI_TABLE_UPGRADE`
mechanism — no BIOS flash required.

```
# What changed (before → after):
Current Power Limit:  50W → 65W
Sustained avg power: 45.7W → 53.1W (Genshin Impact, with CPU undervolt)
GPS GETPPL:          missing → PL1=45W, PL2=65W
GPS PSHAREPARAMS:    broken → 44-byte buffer with PPMD sensor
Touchpad:            working → still working
```

## Table of Contents

1. [Hardware](#hardware)
2. [How It Works](#how-it-works)
3. [Why SSDT Override Alone Fails](#why-ssdt-override-alone-fails)
4. [What Was Patched](#what-was-patched)
5. [Reproduction Guide](#reproduction-guide)
6. [File Manifest](#file-manifest)
7. [Results](#results)
8. [Known Issues](#known-issues)
9. [Key Learnings](#key-learnings)

---

## Hardware

| Component | Value |
|-----------|-------|
| Machine | Lenovo LOQ Essential 15IRX11 83SC |
| CPU | Intel i5-13450HX (Raptor Lake, 10C/16T) |
| GPU | NVIDIA RTX 5050 Mobile (GB207, 10de:2d98) |
| TGP | 50W base + 15W CTGP + PPAB = **65W max** |
| BIOS | SECN22WW (05/21/2026) |
| OS | CachyOS (Arch-based, rolling) |
| Kernel | 7.2.3-1-cachyos |
| Bootloader | Limine |
| NVIDIA driver | 610.57.04 (open) |
| DSDT | 660,250 bytes (patched) |
| CB-01 SSDTs | 22 tables (all patched) |

---

## How It Works

### ACPI Table Override Mechanism

Linux kernels with `CONFIG_ACPI_TABLE_UPGRADE=y` support replacing ACPI tables at boot
via an uncompressed cpio archive placed before the initramfs in the boot chain:

```
Boot chain: BIOS → Limine → [dsdt.cpio] → [initramfs] → kernel → userspace
                   ↑                    ↑
              loaded FIRST         loaded SECOND
              (ACPI tables)        (rootfs)
```

The kernel scans `kernel/firmware/acpi/` inside the cpio and:
1. **Override path**: Replaces firmware tables with matching (Signature + OEM_ID + OEM_Table_ID)
   if initrd revision > firmware revision
2. **Install path**: Adds non-matching tables as new ACPI tables (but these do NOT enter
   the namespace — only override-path replacements work)

### Why SSDT Override Alone Fails

The Lenovo LOQ BIOS has **22 SSDTs all sharing the identity** `(SSDT, LENOVO, CB-01)`:

```
XSDT position: SSDT1(86KB) SSDT2(262B) SSDT3(5.7KB) SSDT4(7.9KB)=NPCF ... SSDT22
All have:      Signature=SSDT, OEM_ID=LENOVO, OEM_Table_ID=CB-01
```

The kernel matches initrd tables to firmware tables **positionally** — first unclaimed
match wins. All 22 firmware SSDTs and all 22 initrd SSDTs share the same tuple, so the
kernel pairs them in XSDT order: firmware SSDT#1 ← initrd SSDT#1, etc.

**The catch**: The kernel also checks `firmware_rev >= initrd_rev → SKIP`. Factory SSDTs
have rev 0x01. Initrd SSDTs must have rev ≥ 0x02 or they're silently dropped.

### The Solution

1. **DSDT override**: Embed the NPCF device directly in the DSDT (works reliably, only 1 DSDT)
2. **SSDT override**: Provide all 22 CB-01 SSDTs with rev 0x02, modified only for the NPCF
   table (ssdt04) which gets GPS fixes

### Why NPCF Must Be in DSDT

The nvidia-acpi driver hardcodes the ACPI path `\_SB.NPCF._DSM` (nv-acpi.c:785-793).
NPCF must be at `\_SB` scope. The original BIOS puts NPCF inside the SSDT, but SSDT
override is unreliable with shared CB-01 identities. Embedding NPCF in the DSDT at
`Scope(\_SB)` guarantees the driver finds it.

---

## What Was Patched

### 1. DSDT — NPCF Device Embedded

The stock DSDT only has `External(_SB_.NPCF,...)` and `Notify(NPCF,...)`. We:
- Removed the `External` declaration (causes `AE_ALREADY_EXISTS`)
- Added `External` for `GPSS` and `NPCS` (FieldUnitObj references)
- Inserted a complete `Device(NPCF)` at `Scope(\_SB)` with:

| Method | Content |
|--------|---------|
| `_HID` | `"NVDA0820"` (Name string, not EisaId — 4 vendor chars fail EisaId) |
| `_UID` | `"NPCF"` |
| `_STA` | `0x0F` (present, enabled, functioning) |
| `_INI` | Sets `GPSS=1`, `NPCS=1` via `CondRefOf` in PEGP OperationRegion |
| `_DSM` | UUID `36b49710-2483-11e7-9598-0800200c9a66`, rev 0x200 |
| func0 | `Buffer(4){0x07,0x01,0x00,0x00}` — bits 0,1,2 + bit8=DC support |
| func1 | 14-byte config, checksum 0xAB (two's complement) |
| func2 | 49-byte dynamic params — TGPA=65W, TPPA=135W, MAGA=120W |
| func8 | 22-byte DC system power limits |

### 2. SSDT#4 (NPCF Table, 7946→8005 bytes) — GPS Pipeline Fix

The original NPCF SSDT contains PEGP scope with the GPS method. Changes:

| Patch | Before | After | Why |
|-------|--------|-------|-----|
| GPS `_DSM` GPSS guard | `If(GPSS!=Zero)` routes to GPS | Guard removed | `_INI` writes GPSS too late — driver probes GPS at boot before NPCF._INI runs |
| GPS func0 byte4 | `0x01` | `0x11` | Adds bit 4 = GETPPL (func 0x24) support |
| GPS Case(0x24) | missing (returns 0x80000002) | Returns `{V1, PL1=45W, PL2=65W}` | Driver's PPL version check expects Major=1 |
| GPSP buffer | `Buffer(0x28)` (40 bytes) | `Buffer(0x2C)` (44 bytes) | PPMD field at offset 0x28 was outside the buffer |
| RETN status bits | `0x00000000` | `0x00010100` | Declares TGPU + PPMD sensors as supported |
| PPMD field | absent | `PPMD = 0x0700` | Platform Power Mode Data for dynamic boost |
| OEM Revision | `0x01` | `0x02` | Required for kernel to accept override (must be > firmware rev) |

### 3. All 22 CB-01 SSDTs — OEM Revision Bump

Every CB-01 SSDT had OEM Revision = 0x01 (same as firmware). Kernel's
`acpi_table_initrd_override()` silently skips if `firmware_rev >= initrd_rev`.
All 22 were hex-patched to rev 0x02 + checksum recalculated.

### 4. CPU Undervolt (Optional, Complementary)

Applied CPU=-75mV via `intel-undervolt`. The CPU and GPU share a single-fan heatsink
(CPU heatpipe + GPU heatpipe → one fan). Reducing CPU voltage reduces thermal soak,
giving the GPU ~3.9W more sustained power.

---

## Reproduction Guide

> [!CAUTION]
> Do NOT skip steps or modify files you don't understand. A wrong checksum, wrong OEM
> revision, or misaligned CPIO structure will silently fail or panic at boot.

### Prerequisites

```bash
# Arch/CachyOS
sudo pacman -S acpica iasl intel-undervolt
# acpi_call DKMS (for testing)
yay -S acpi_call-dkms
```

### Step 1: Extract XSDT Tables

```bash
sudo acpidump -b -o /tmp/acpi_dump.bin
acpixtract -a /tmp/acpi_dump.bin -d ./xsdt/
```

### Step 2: Identify the NPCF Table

```bash
for f in ./xsdt/ssdt*.dat; do
    echo "$(stat -c%s "$f") $f"
done | sort -n
# NPCF table = 7946 bytes on LOQ 15IRX11
```

### Step 3: Decompile + Identify Patch Targets

```bash
iasl -d ./xsdt/ssdt4.dat  # if ssdt4 is the 7946B table
# The GPS method is at lines ~406-536 in the decompiled DSL
# The NPCF device is at lines ~844-1186
```

### Step 4: Patch DSDT

```bash
# Decompile stock DSDT
iasl -d ./xsdt/dsdt.dat

# Run the patch script
python3 scripts/patch_dsdt.py dsdt.dsl dsdt_patched.dsl

# Compile
iasl -tc dsdt_patched.dsl
# Produces dsdt_patched.aml (should be ~660KB)
```

### Step 5: Patch NPCF SSDT + Build CPIO

```bash
python3 scripts/hexpatch_ssdt.py ./xsdt/
# This:
#   1. Copies all 22 SSDTs to cpio_build/kernel/firmware/acpi/
#   2. Hex-patches OEM Rev to 0x02
#   3. Decompiles, patches (GPS guard removal, GETPPL, PPMD), recompiles ssdt04
#   4. Builds dsdt.cpio
```

### Step 6: Deploy

```bash
# Backup current
sudo cp /boot/dsdt.cpio /boot/dsdt.cpio.bak.$(date +%s)

# Deploy new
sudo cp dsdt.cpio /boot/dsdt.cpio
```

### Step 7: Update Limine Config

Ensure your Limine NPCCF entry loads dsdt.cpio as the **first** module:

```
entry: CachyOS-NPCCF
protocol: linux
path: boot():/016e.../linux-cachyos/vmlinuz
module_path: boot():/dsdt.cpio
module_path: boot():/016e.../linux-cachyos/initramfs
cmdline: quiet nowatchdog splash rw rootflags=subvol=/@ root=UUID=...
```

### Step 8: Reboot + Verify

```bash
# Reboot into the NPCCF entry
# Then:
chmod +x scripts/verify.sh
./scripts/verify.sh
```

---

## File Manifest

```
loq-npcf/
├── README.md                          # This file
├── scripts/
│   ├── extract_xsdt.sh                # Step 1: dump ACPI tables
│   ├── patch_dsdt.py                  # Step 4: embed NPCF in DSDT
│   ├── hexpatch_ssdt.py               # Step 5: patch SSDTs + build CPIO
│   └── verify.sh                      # Step 8: post-boot verification
├── sources/
│   ├── ssdt04_patched.dsl             # Modified NPCF+GPS SSDT (the core patch)
│   └── cuda-matmul.cu                 # GPU stress test (N=4096 float matmul)
├── data/
│   ├── genshin_power.csv              # 18min Genshin (stock 50W, 530 samples)
│   ├── genshin_power_v7.csv           # 5min Genshin (65W, 300 samples)
│   └── genshin_power_v7_undervolt.csv # 5min Genshin (65W + CPU -75mV)
└── docs/
    └── REPORT.md                      # Detailed technical report
```

**Not in repo** (too large / system-specific):
- `dsdt_live.dsl` (135K lines, 4.5MB decompiled DSDT)
- `dsdt_live.dat` (660KB patched DSDT binary)
- `nvidia-open-telemetry/` (nvidia-open driver source clone)
- `cpio_build/` (build artifacts — generated by `hexpatch_ssdt.py`)

---

## Results

### Genshin Impact Power Comparison

5-minute open-world tests, GPU utilization 90-99%:

| Metric | Stock (50W) | Patched (65W) | Patched + CPU -75mV |
|--------|------------|---------------|---------------------|
| Avg power | 45.7W | 49.2W | **53.1W** |
| Avg temp | 86.1°C | 85.7°C | **84.4°C** |
| Samples >55W | ~0 | 47 | **105** |
| Steady state | 43-47W @ 87°C | 45-50W @ 87°C | **49-53W @ 87°C** |

### Synthetic Stress (cuda-matmul, 30s)

- 65.27W sustained at 70-75°C, 2257-2295 MHz — PPAB fully working

### Why 87°C Limits Sustained Power

The GPU boosts to 65W initially but hits the 87°C thermal target within ~10 seconds,
then reduces power to maintain that temperature. This is NVIDIA's VBIOS-enforced limit
for the RTX 5050 (GB207) — universal across all OEMs, cannot be overridden via software.

The CPU undervolt helps by reducing shared heatsink temperature, giving ~3.9W more
sustained GPU power within the same thermal budget.

---

## Known Issues

| Issue | Status | Notes |
|-------|--------|-------|
| `PlatformRequestHandler` NV_ERR_INVALID_DATA ×2 | Cosmetic | Boot-time error from GPS sensor probe timing. Does not affect runtime power management. |
| `AE_ALREADY_EXISTS \_SB.NPCF` ×1 | Expected | DSDT override wins over 7946B SSDT — correct behavior. |
| `nvidia-powerd` zero activity logs | Cosmetic | Service runs but doesn't log after startup. Power limits work via NVPCF. |
| 87°C thermal target limits sustained power | By design | NVIDIA VBIOS spec. Cannot be raised via ACPI. |
| GPS func0x24 GETPPL unused by driver | By design | PPL values are informational only — not cached by driver. |

---

## Key Learnings

### 1. Kernel SSDT Override Requires OEM Rev > Firmware Rev

`acpi_table_initrd_override()` silently skips if `firmware_rev >= initrd_rev`. No error
message is printed. The factory CB-01 SSDTs all have rev 0x01. Initrd SSDTs MUST have
rev ≥ 0x02.

### 2. All CB-01 SSDTs Share Identity → Positional Matching

With 22 identical `(SSDT, LENOVO, CB-01)` tables, the kernel matches them positionally:
first unclaimed initrd SSDT replaces the first firmware SSDT in XSDT order. You must
provide ALL 22 in correct XSDT order.

### 3. Install-Path SSDTs Don't Enter ACPI Namespace

A table with a unique OEM_Table_ID (not matching any firmware table) is added via
`acpi_install_physical_table()` but never processed into the ACPI namespace. Only
override-path replacements affect the running system.

### 4. NPCF Must Be at `\_SB` Scope

`nv-acpi.c:785-793` hardcodes `pathname "\\_SB.NPCF._DSM"`. NPCF inside PEGP scope
is invisible to the nvidia driver.

### 5. acpi_call Requires 0x Prefix for Hex Bytes

The DKMS acpi_call module parses `{10 97 b4 36}` as **decimal** values. Always use
`{0x10, 0x97, 0xb4, 0x36}` for correct UUID matching.

### 6. GPS Method Has a GPSS Guard

PEGP's `_DSM` checks `GPSS != Zero` before dispatching to `GPS()`. GPSS lives in an
OperationRegion (NOPR at 0x7387C018) that may not be mapped when `_INI` runs. The fix:
remove the guard from the `_DSM` in the patched SSDT.

### 7. GPS Revision Must Be 0x200

The GPS method rejects any revision other than `0x0200`. The nvidia driver passes 0x200
(GPS_2X). acpi_call tests must use `0x200`, not `0x00`.

### 8. func1 Checksum Is Two's Complement Negate

Sum all bytes except the last, negate (invert + add 1), compare to last byte.
Example: `sum({0x20,0x03,0x01,0x00,0x25,0x04,0x05,0x01,0x01,0x01,0x00,0x00,0x00}) = 0x55`
→ `(~0x55)+1 = 0xAB`.

### 9. The 87°C Thermal Target Governs Power, Not the 65W Limit

GPU boosts to 65W initially, hits 87°C within ~10s, then reduces power to maintain
target temperature. NTCC=0x57 (87°C) is the VBIOS thermal target. Accept 87°C as
the operating ceiling — it's universal for RTX 5050 (GB207).

---

## License

This project is licensed under the **GNU General Public License v3.0** — see the [LICENSE](LICENSE) file for details.

ACPI table patching can brick your system if done incorrectly. Always keep a backup.
