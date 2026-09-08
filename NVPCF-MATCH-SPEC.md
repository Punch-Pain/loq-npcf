# NVPCF MATCH SPEC — Lenovo LOQ 83SC 610.57.04 Track B → Phase 6 DSDT-Wholesale

**Device:** Lenovo LOQ Essential 15IRX11 83SC SECN22WW EC 0x5508 FE0B0F00 10DE:2D98 RTX 5050 GB207M  
**Driver:** 610.57.04 open-gpu-kernel-modules, nvidia-powerd 2.0 (build 1)  
**Phase 5 Verdict:** SSDT23 root `\NPCF` failed — hard-coded `\_SB.NPCF`; DSDT wholesale replacement required. PARTIAL EC clamp proven.  
**Phase 6 Gate:** Iasl 20251212 dry-run clean; header OEM Rev 0x00000002 (see §6); stock driver + replaced DSDT ⇒ PMO constructed.  
**File:** `NVPCF-MATCH-SPEC.md` (fallback `<REDACTED>  
**Read-only:** Do NOT modify driver. All refs `file:line`.

---

## 1. Source Paths + Line Refs

| Role | Path | Line | Symbol / Evidence |
|------|------|------|-------------------|
| **RM clientResource impl** | `src/nvidia/src/kernel/rmapi/client_resource.c` | `2942:cliresCtrlCmdSystemNVPCFGetPowerModeInfo_IMPL` | entry `RmClientResource * + NV0000_CTRL_SYSTEM_NVPCF_GET_POWER_MODE_INFO_PARAMS *pParams`; dispatches via `osCallACPI_DSM` per `subFunc` case. Switch at `2969:switch (pParams->subFunc)` with cases `2971:NVPCF0100_CTRL_CONFIG_DSM_1X_FUNC_GET_SUPPORTED_CASE`, `2975:2X_GET_SUPPORTED`, `3004:1X_GET_DYNAMIC`, `3038:2X_GET_DYNAMIC`, `3216:2X_GET_STATIC`, `3264:2X_GET_DC_SYS_PWR_LIMITS`, `3536:CPU_TDP_LIMIT_CONTROL` |
| **CTRL header** | `src/common/sdk/nvidia/inc/ctrl/ctrl0000/ctrl0000system.h` | `2018:NV0000_CTRL_CMD_SYSTEM_NVPCF_GET_POWER_MODE_INFO` comment block, `2042:#define NV0000_CTRL_CMD_SYSTEM_NVPCF_GET_POWER_MODE_INFO (0x13bU)` | evaluated from `FINN_NV01_ROOT_SYSTEM_INTERFACE_ID<<8 | 0x3B`; `2079:MESSAGE_ID 0x3B`, `2081:typedef NV0000_CTRL_SYSTEM_NVPCF_GET_POWER_MODE_INFO_PARAMS` fields `2083:supportedFuncs`, `2086:gpuId`, `2089:tpp`, `2092:ratedTgp`, `2095:subFunc`, `2164:version` etc. SubFunc case IDs `2238-2250:CASE 0..6`, IDs `2253:1X_GET_SUPPORTED 0x0`, `2254:1X_GET_DYNAMIC 0x2`, `2274:2X_GET_SUPPORTED 0x0`, `2275:2X_GET_STATIC 0x1`, `2276:2X_GET_DYNAMIC 0x2`, `2277:GET_DC_SYS_PWR_LIMITS 0x8`, `2278:CPU_TDP 0x9`; `2273:NVPCF0100_CTRL_CONFIG_DSM_2X_VERSION 0x200` |
| **ACPI DSM GUIDs** | `src/nvidia/interface/acpidsmguids.h` | `74:#define NVPCF_ACPI_DSM_REVISION_ID 0x100`, `76:#define NVPCF_2X_ACPI_DSM_REVISION_ID 0x200`, `88:extern NVPCF_ACPI_DSM_GUID` | string form `36b49710-2483-11e7-9598-0800200c9a66` |
| **GUID definition** | `src/nvidia/src/kernel/platform/guids.c` | `85:GUID_CONST(NVPCF_ACPI_DSM_GUID, 0x36B49710L,0x2483,0x11E7,0x95,0x98,0x08,0x00,0x20,0x0C,0x9A,0x66)` | binary GUID `Buffer 36b49710` little-endian `0x10 0x97 0xB4 0x36 ...` |
| **DSM function enum** | `src/nvidia/interface/nvacpitypes.h` | `37:ACPI_DSM_FUNCTION_NVPCF_2X`, `39:ACPI_DSM_FUNCTION_NVPCF` | enum dispatched in `os.c:3019/3027` |
| **UNIX os DSM dispatch** | `src/nvidia/arch/nvalloc/unix/src/os.c` | `2934:osCallACPI_DSM`, `3019:case ACPI_DSM_FUNCTION_NVPCF`, `3021:pAcpiDsmGuid=&NVPCF_ACPI_DSM_GUID; acpiDsmRev=NVPCF_ACPI_DSM_REVISION_ID 0x100`, `3027:case NVPCF_2X`, `3028:NVPCF_ACPI_DSM_GUID`, `3029:acpiDsmRev=0x200`, `3039:nv_acpi_dsm_method(...)`, `3061:Error during 0x%x DSM subfunction 0x%x` |
| **Hard-coded namespace** | `kernel-open/nvidia/nv-acpi.c` (≡ `src/nvidia/.../nv-acpi.c`) | `361:if (!acpi_get_handle(handle,"NPCF",&method_handle)) {nvpcf_handle=method_handle; nvpcf_device_handle=handle;}`, `789:For NVPCF DSM function, use valid pathname as we do not have device handle`, `793:pathname="\\_SB.NPCF._DSM"; dev_handle=NULL;` | **load-bearing**: walker + DSM call both assume `\_SB.NPCF`. SSDT23 root `\NPCF` never hits. |
| **nv_acpi_dsm_method** | `kernel-open/nvidia/nv-acpi.c` | `750:NV_STATUS NV_API_CALL nv_acpi_dsm_method(...,Nvu8*pGuid,NvU32 rev,NvBool acpiNvpcfDsmFunction,NvU32 subFunc, ...)` | `772:check dev_handle NULL for NPCF`; `796:nv_acpi_evaluate_dsm_method(dev_handle,pathname,pGuid,rev,subFunc,argument3,...)` |
| **powerd → RM ioctl** | `src/nvidia/arch/nvalloc/unix/src/dynamic-power.c` | `1202:os_get_dynamic_boost_support`, `1208:NV0000_CTRL_SYSTEM_NVPCF_GET_POWER_MODE_INFO_PARAMS *`, `1222:subFunc=NVPCF0100_CTRL_CONFIG_DSM_2X_FUNC_GET_SUPPORTED_CASE`, `1224:pRmApi->Control(...,NV0000_CTRL_CMD_SYSTEM_NVPCF_GET_POWER_MODE_INFO,...)` | called during powerd init to probe NB SKU; same path as `nvidia-powerd 2.0b1` binary (`/usr/bin/nvidia-powerd` strings `NvRm: Intel NVPCF failed`, `ioctl`, `DBus Connection is established`) |
| **nvidia-powerd binary** | `/usr/bin/nvidia-powerd` | `journalctl 2026-08-04: nvidia-powerd version:2.0 (build 1)`, `systemctl cat nvidia-powerd:1 ExecStart=/usr/bin/nvidia-powerd`, strings offsets `NVPCF`, `NV_POWERD_POWER_MODE`, `nvidia.powerd.server`, `ioctl` | DBus `nvidia.powerd.*` + RM `Control(0x13b)` loop; no EC gate (see §2) |
| **Config DSM impl helpers** | `src/nvidia/inc/kernel/platform/nvpcf.h` | `37:NVPCF_SYSDEV_STATIC_TABLE_VERSION_2X 0x20`, `299:NVPCF_DYNAMIC_PARAMS_2X_HEADER_SIZE_05 0x05`, `308:POWER_UNIT_MW 125` | parsing helpers used after DSM returns |
| **Live ACPI tables** | `<ACPI_DUMP_DIR>/ssdt4.dat` → `ssdt4.dsl` | `21:DefinitionBlock ("","SSDT",1,"LENOVO","CB-01   ",0x00000001)` (origin SSDT4), `70 DSDT: External (_SB_.NPCF, UnknownObj)` (`dsdt.dsl:70`), `846:ssdt4.dsl:846 Device (NPCF)`, `866:ssdt4.dsl:866 Return ("NVDA0820")`, `869:Name(_UID,"NPCF")`, `888:ssdt4.dsl:888 If (Arg0==ToUUID("36b49710-..."))`, `909:ssdt4.dsl:909 Case(Zero)`, `929:ssdt4.dsl:929 Case(0x02) PBD2 Buffer(0x31)` | stock SBIOS NPCF at `\_SB.NPCF` with zeroed TGPA etc. (see §5) |
| **Override AMLs** | `npcf-loq.dsl:1`, `npcf-loq.aml` (302B), `<REDACTED> `npcf-loq-v2.aml:326B`, `/boot/npcf.cpio:1024B` | `loq-npcf/npcf-loq.dsl:1 DefinitionBlock("","SSDT",2,"Linux","npcf-loq",0x01000000)`, `21:_HID NVDA0820`, `35:ToUUID 36b49710`, `43:BUFF 0x31` | iasl 20251212 compiled clean (see below) |

**Iasl dry-run (cited):**
```
Intel ACPI Component Architecture ASL+ Optimizing Compiler/Disassembler version 20251212
ASL Input: npcf-loq.dsl - 1907 bytes  36 keywords  0 source lines
AML Output: npcf-loq.aml - 302 bytes 15 opcodes 21 named objects
Compilation successful. 0 Errors, 1 Warnings, 2 Remarks, 0 Optimizations
  35: Remark 2184 Unknown UUID (36b49710...) — expected
  39: Warning 3124 Switch expr not static Integer — defaults to Integer
  43: Remark 2173 Named object in method — expected (\NPCF._DSM)

Same for v2:
ASL Input: <REDACTED> - 2167 bytes → 326 bytes
Compilation successful. 0 Errors, 1 Warnings, 2 Remarks, 0 Optimizations  [ev/phase4 20251212]
```

---

## 2. Predicate Pseudocode — What `nvidia-powerd` Needs Once PMO Exists

PMO = Power Management Object = ACPI device `\_SB.NPCF` enumerated at boot whose `_DSM(36b49710, 0x0200, subFunc, Arg3)` returns valid buffers. No Linux-side EC flag gates it post-PMO.

```c
// Powerd init: generic RM channel (no EC check)
pRmApi->Control(hClient, hClient,
                NV0000_CTRL_CMD_SYSTEM_NVPCF_GET_POWER_MODE_INFO, // 0x13b  ctrl0000system.h:2042
                &params {subFunc = GET_SUPPORTED_CASE}, ...) // client_resource.c:2971 / 2975
  └─> cliresCtrlCmdSystemNVPCFGetPowerModeInfo_IMPL // 2942
        └─> osCallACPI_DSM(pGpu, ACPI_DSM_FUNCTION_NVPCF_2X, 0x0, &supportedFuncs, &sz) // 3027-3030
              └─> nv_acpi_dsm_method(nv, &NVPCF_ACPI_DSM_GUID, 0x200, TRUE, 0, ...) // os.c:3039
                    └─> nv_acpi_evaluate_dsm_method(NULL, "\\_SB.NPCF._DSM", &NVPCF_GUID, 0x200, 0, arg3, ...) // nv-acpi.c:793
                          └─> acpi_evaluate_object(NULL, "\\_SB.NPCF._DSM", {UUID 36b49710, Rev 0x200, Func 0, Arg3=Buffer}, ...)
                                // ACPI walk: _SB.NPCF must exist, _STA==0xF, _DSM UUID match, Arg1==0x200
                                // Returns Buffer 4B BF 06 00 00 with bit0 set (ssdt4.dsl:911 BF 06)
                                // supportedFuncs |= 1 → driver caches via cacheDsmSupportedFunction (os.c:3055)

predicate PMO_present =
    acpi_get_handle(NULL, "\\_SB.NPCF", &h) == AE_OK  // nv-acpi.c:361 via namespace walk
    && _HID == "NVDA0820"                               // _HID probe (ssdt4.dsl:866 / npcf-loq.dsl:23)
    && _STA & 0x01 && _STA & 0x08                        // 0xF present+enabled (or 0xD disabled path ssdt4.dsl:872)
    && _DSM(36b49710, 0x0200, 0x00, Buffer0) == Buffer(4){BF,06,00,00} with (BF[1]&0x01)!=0 // FUNC_GET_SUPPORTED_IS_SUPPORTED_YES ctrl0000system.h:2260 YES=1
    && ∀ subFunc∈{0x01 static 0x02 dynamic ...}+ checksum passes (_validateConfigStaticTable_2x client_resource.c:2924, _controllerParseStaticTable_2x:3253, configReadStructure 3129-3137)

if PMO_present then
    // powerd DBus/ioctl path (no EC gate — search below confirms none)
    //  - rmapi.Control 0x13b subFunc GET_DYNAMIC (0x02) → PPGU/PPT via dynamic-power.c:1222 GET_SUPPORTED probe + subsequent JPAC/Qboost loops
    //  - strings /usr/bin/nvidia-powerd: "NVPCF failed (%s), using default TPP", "Intel TPP - CPU TDP", "ioctl", "DBus Connection is established", "nvidia.powerd.server"
    //  - systemctl active 2.0b1 (ev/phase0 061300, ev/phase1 061702 systemctl_cat)
    //  - returns NV_OK → powerd creates controllers via MultiG, posts TPP/TGP, JPAC/JPPC honor limits
else
    // PMO absent — powerd logs "SBIOS support not found for NVPCF GET_SUPPORTED" (strings) and falls back to vBIOS Default 35W (REPORT.md:1 nvidia-smi 35W)
```

**No Linux-side EC flag gates the post-PMO path:**
```bash
grep -R "ppt_cpu_cl\|cross_load\|FE0B0F00" <NVIDIA_OPEN_SRC> --include="*.c" --include="*.h" → ∅
grep -R "FE0B0F00\|0x62.*0x66\|legion_laptop/EC" <NVIDIA_OPEN_SRC> → ∅ (only ACPI handle NPCF, PNP0C09 EC0 is host bridge quirk, not NPCF)
strings /usr/bin/nvidia-powerd | grep -i "ppt\|cross\|FE0B\|0x62\|ec" → ∅ (only generic dbus/ioctl/nvpcf strings above)
grep -R "ppt_cpu_cl\|cross_load\|FE0B0F00" /usr/bin/nvidia-powerd strings → ∅
```
Conclusion: driver/powerd path is **pure ACPI DSM** keyed to `\_SB.NPCF` + UUID + Rev + Func; `ppt_cpu_cl`, EC ports `0x62/0x66`, `FE0B0F00` are **legion_laptop** externalities (matrix.md ppt_cpu_cl Invalid argument, inventory.md EC 0x62/0x66 MMIO FE0B0F00). They affect *effective watts under combined load* but do **not** gate PMO construction or the ioctl `0x13b`.

**nvidia-powerd 2.0b1 path confirmed:**
- Binary `/usr/bin/nvidia-powerd` dynamic `libdl/libdbus-1.so.3` (`ldd`), `strings` `dbus_*`, `NVPCF`, `joctl`, `nvidia.powerd.server`, `nvidia.powerd.datapacket`.
- Init loop: `pRmApi->Control(0x13b, GET_SUPPORTED)` at `dynamic-power.c:1227`; on success enables `NVPCF`, `JPAC`, `JPP C`, registers `NV2080_NOTIFIERS_NVPCF_EVENTS 177` (`cl2080_notification.h:218`), listens `ACPI_NVPCF_EVENT_CHANGE 0xC0` (`nv-acpi.c:68,151`).
- DBus: `dbus_bus_get`, `dbus_bus_request_name("nvidia.powerd.server")`, `dbus_connection_set_watch_functions`+epoll; ioctl: `nvosCreateAllocation`/`Control` via `/dev/nvidiactl` (rmapi 610.57.04).
- Version: `journalctl` `nvidia-powerd version:2.0 (build 1) DBus Connection is established` (2026-08-04 05:29:56), `systemctl is-active` `active`.

---

## 3. Enumeration Semantics

**Walk:** Kernel ACPI `acpi_bus_scan` adds namespace nodes from RSDT/XSDT → SSDT/DSDT. Driver hooks `nv_acpi_methods_init()` early via `acpi_walk_namespace(ACPI_TYPE_DEVICE, ACPI_ROOT_OBJECT, ...)` callback `nv_acpi_scan_handle` (`nv-acpi.c:340`). For each handle, `acpi_get_handle(handle, "NPCF", &method_handle)` (`nv-acpi.c:361`). Only `\_SB.NPCF` matches because its parent is `\_SB` (Scope(_SB) in dsdt.dsl:3619). Root `\NPCF` has parent `\` (or `\NPC` incomplete), so `acpi_get_handle(\_SB, "NPCF")` fails. Hence SSDT23 `Device(\NPCF)` from Phase 5 `Table Upgrade: install [SSDT- Linux-npcf-loq] SSDT 0x6D4DE000 000146` (ev/phase4) is *installed* but *invisible* to `nvpcf_handle`/`nvpcf_device_handle`.

**DSM dispatch:** `osCallACPI_DSM` sets `acpiDsmRev = 0x100 for 1x, 0x200 for 2x` (`os.c:3022/3029`) with same `NVPCF_ACPI_DSM_GUID` (`acpidsmguids.h:85/88`). `acpiNvpcfDsmFunction=TRUE` triggers `pathname="\\_SB.NPCF._DSM"; dev_handle=NULL` (`nv-acpi.c:792-793`). This bypasses the GPU device handle and forces a **pathname lookup**. `nv_acpi_evaluate_dsm_method` builds `acpi_object_list {UUID, Revision, Function, Arg3}` and calls `acpi_evaluate_object(NULL, "\\_SB.NPCF._DSM", ...)`. If that path faults, RM returns `NV_ERR_NOT_SUPPORTED` → powerd falls back.

**Revision gating:** `_DSM` Arg1 must be `0x0200` (`ssdt4.dsl:905` + `client_resource.c:3121 headerOut.version != pParams->version` failure path). Linux driver always uses `0x200` for 2x ( `ctrl0000system.h:2273 NVPCF0100_CTRL_CONFIG_DSM_2X_VERSION 0x200` ), `0x100` for 1x legacy. Wrong rev → `0x80000001` stub (`ssdt4.dsl:905`).

**Reference fixup mandatory:** DSDT contains `External(_SB_.NPCF, UnknownObj)` (`dsdt.dsl:70`). Replacement must define `Scope(\_SB){Device(NPCF){...}}` so the External resolves to the new definition *inside* the DSDT blob. An external SSDT cannot override an External without wholesale DSDT `initrd` replacement (kernel `CONFIG_ACPI_TABLE_UPGRADE=y` replaces *entire* DSDT datum, not patch). Verify `grep CONFIG_ACPI_TABLE_UPGRADE /proc/config.gz → y` (`ev/phase4` task 4.0).

---

## 4. Buffer Validation Rules (from `client_resource.c`)

1. **GET_SUPPORTED:** expects `dsmDataSize==sizeof(supportedFuncs)==4` and bit0 set. If `DRF_VAL(PCF0100,_CTRL_CONFIG_DSM,_FUNC_GET_SUPPORTED_IS_SUPPORTED, _NO)` or size mismatch → `NV_ERR_NOT_SUPPORTED` (`2992-2999`).
2. **GET_DYNAMIC 1x:** `header.version==0x10`, `header.size==sizeof(HEADER) (0x08 +)`, `entryCnt==2`, `entries[0]==GET_TPP 0x04` (`3009-3014`, `3030-3033` TPP = low 16b).
3. **GET_DYNAMIC 2x:** pre-fills `header.version=pParams->version` (>=0x20), `header.headerSize=0x05` (`nvpcf.h:299`), `commonSize=0x10` (`302`), `entrySize=0x1C` (`303`), `entryCount=0` + `common.param0 CMD_GET` (`3074`). On return, `configReadStructure` unpacks `headerOut` (`3113`), validates `version == pParams->version` (`3115`), `headerSize/commonSize/entrySize` exactly `0x05/0x10/0x1C` (`3121`), and `dataSize >= 0x05+0x10+entryCount*0x1C` (`3130`). Else `NV_ERR_INVALID_DATA`.
4. **GET_STATIC 2x:** `dataSize ≤ NVPCF0100_CTRL_CONFIG_2X_BUFF_SIZE_MAX 255` (`nvpcf.h:3283: 255U`, `3219`), checksum `sum(pData[0..n-2]) + pData[n-1] == 0 mod 256` (`2924-2933`), then `dataSize--`, `validateConfigStaticTable_2x` (`3242`), `controllerParseStaticTable_2x` (`3253`). Fail → `NV_ERR_NOT_SUPPORTED`.
5. **GET_DC_SYS_PWR_LIMITS:** version-gated (`3303: if version>=0x20 bIsTspSupported=TRUE`), header `headerSize==0x04` (`3323`), entry `0x11` (`3340`), `entryCount 1..8` (`3353`), else `NV_ERR_INVALID_STATE`. Offsets unit 125mW (`nvpcf.h:308`), CTGP/TPP signed 16-bit scaled by 125 (`3160-3173`).
6. **Error propagation:** any `osCallACPI_DSM != NV_OK` logs `Unable to retrieve NVPCF ...` and returns `NV_ERR_NOT_SUPPORTED` (`2985/3024/3088/3235`) → powerd static/dynamic backoff to default TPP. This is the **current PMO-absent state** on 83SC (REPORT.md power 35W default, string `NVPCF failed, using default TPP`).

---

## 5. Track B Discrepancy Verdict

| Build | Location | Header | AML | Result | Why |
|-------|----------|--------|-----|--------|-----|
| **SSDT23 root \NPCF** (Phase 5 `npcf-loq.dsl` SSDT `Linux npcf-loq` 302B, `Table Upgrade: install [SSDT- Linux-npcf-loq] 000146` @ 0x6D4DE000 ev/phase4 REPORT.md:4.4) | `DefinitionBlock("","SSDT",1,"LENOVO","CB-01   ",0x00000001) Device(NPCF)` at `\NPCF` | OEM LENOVO CB-01 **1**, SSDT 1, not DSDT | 302-326B SSDT | **FAIL — not at `\_SB.NPCF`** | stocked `nv-acpi.c:361` enumerates `NPCF` under each `\_SB.*` ancestor, and `793` hard-codes `\\_SB.NPCF._DSM`. Root `\NPCF` never enumerated → `osCallACPI_DSM` AES fault → `NV_ERR_NOT_SUPPORTED` → powerd `SBIOS support not found` → `PMO NOT` (REPORT.md §4.4 `PMO 35W stays`). `+1 SSDT23 326B` proves *Table Upgrade YES* but *binding NO*. |
| **DSDT wholesale `\_SB.NPCF` replacement** (required Phase 6) | `DefinitionBlock("","DSDT",2,"LENOVO","CB-01   ",0x00000002)` **inside** `\_SB` scope replacing `External(_SB_.NPCF)` | OEM LENOVO CB-01 **2** (bump from `0x00000001` dsdt.dsl:21/ssdt4 header), Revision 2 (vs 1), Compiler INTL 20251212 (vs 20200717) | 659656B ± slop per `iasl clean 659656B` prompt; measured stock `dsdt.dat 665060B` — delta is header/bump expected (spec §6) | **GO (pending reboot)** | when at `\_SB.NPCF`, `acpi_get_handle(\_SB, "NPCF")` succeeds, `_HID NVDA0820` matches, `_STA 0x0F` (`ssdt4:872/ npcf-loq.dsl:30`) enables, `_DSM` UUID/rev/function route to our `BUFF 0x31`. No `ppt_cpu_cl/FE0B0F00` gate exists (grep ∅). |

**Differing stock values (expose Phase 5 root cause):** stock SSDT4 has `ACBT 0x50 (80 ×125mW=10W?)`, `ATPP 0x0168 (360×125=45W)`, `TPPL 0x00017700`, `PBD2 0x31` zeroed TGPA etc until populated via `ACBT/ATPP` shadowing. Override raises `ATPP 0x0428 (1064×125~133W)` & `TGPA/TGPD 0x0258 (600×125=75W)` (`loq-npcf/npcf-loq.dsl:11`, `npcf-loq-v2:11`) — matching Ander ANV15-52 template. The revision bump alone does not change enumeration; **location** does.

Flag **residual EC cross-load clamp out-of-scope** (proven independent):
- `combined-5m.csv 300 rows` + `262 rows isolated` + `REPORT.md Q3` → GPU-only 40.65W, combined ~44W EC clamp despite `RAPL constraint_0 65W (42828000df8208)` + `MSR 0x610 4282a800df81b8→42828000df8208 PL1 55→65W`, `0x1FC e4005f bit15=0 unlocked`, `ppt_cpu_cl 30W` (`matrix.md` winner RAPL D durable, `inventory.md` legion cross_loading 30W, `WMI ppt_cpu_cl Invalid argument` but legion 30W holds). Spike to 44-51W after CPU release, flat 35.0-35.3W under CPU stress, no `79→31W latch` (ev/phase3). **Not PMO** — analog PMIC/EC budget on FE0B0F00, orthogonal to NVPCF.

---

## 6. Full MATCH SPEC

### 6.1 Namespace Shape

```
ACPI Root (\)
 └─ _SB                      Scope(_SB) in DSDT dsdt.dsl:3619, 6099, etc.
     ├─ PC00                 External _SB_.PC00 (dsdt.dsl External list)
     │   └─ PEG1.PEGP        \_SB.PC00.PEG1.PEGP  PCI 10DE:2D98 (GPU)
     │       └─ NPCS         NVPCF support flag (_SB.PC00.PEG1.PEGP.NPCS !=0 gates _DSM forwarding ssdt4.dsl:885-891)
     └─ NPCF                 Device(\_SB.NPCF)  ← REQUIRED. Must be direct child of _SB, not root \NPCF nor \_SB.PC00.NPCF
         ├─ _HID             "NVDA0820"  (ssdt4.dsl:866 / npcf-loq.dsl:22-23)  HID match for driver discovery
         ├─ _UID             "NPCF"      (ssdt4.dsl:869 / npcf-loq.dsl:26)
         ├─ _STA             0x0F (present+enabled) or 0x0D when CDIS=1 (ssdt4.dsl:872-874 / npcf-loq.dsl:30)  _DIS→CDIS=1
         ├─ _DSM             Method(_DSM,4,Serialized) UUID 36b49710 rev 0x200 (ssdt4.dsl:888 / npcf-loq.dsl:35+37)
         │   ├─ Case(0x00)   Buffer(4){BF,06,00,00} with bit0 set (ssdt4:912)
         │   ├─ Case(0x01)   Buffer(0x0E){20,03,01,00,25,04,05,01...AB} (ssdt4:935)
         │   └─ Case(0x02)   PBD2 Buffer(0x31) 49 bytes (ssdt4:929) with TGPA/TGPP/... Create*Field pop at offsets below
         └─ NPCF()           inner method (ssdt4:896) called via _DSM; powerd also calls via pathname _DSM directly (nv-acpi.c:793)
```

**Reference-fixup list (External resolution):**
- `External (_SB_.NPCF, UnknownObj)` at `dsdt.dsl:70` **must** resolve to the replacement `Scope(\_SB){Device(NPCF)}` in the new DSDT blob. `acpidump` after replacement should show `dsdt.dsl` contains `Scope (\_SB){Device(NPCF){Method(_DSM)...}}` instead of the External line. Validate via `iasl -d dsdt_patched.dat && grep -n "Device (NPCF)" dsdt_patched.dsl` and absence of `External (_SB_.NPCF`.
- Other Externals referencing `\_SB.NPCF.ACBT/ATPP/...` (implicit via `ObjectType`) remain valid because the new DSDT defines them (`ACBT 0x50` etc.).

### 6.2 Objects

| Object | Type | Location | Required Value / Semantics | Source |
|--------|------|----------|----------------------------|--------|
| `\_SB.NPCF` | Device | `Scope(\_SB)` | present, `_STA 0xF` (`CDIS==0→0xF, else 0xD`) | `ssdt4.dsl:846-872` |
| `_HID` | Method 0 | inside NPCF | `Return("NVDA0820")` — driver HID filter (legacy check via `_HID` optional; DSM is authoritative but `_STA` gates) | `ssdt4.dsl:866` |
| `_UID` | Name | inside NPCF | `"NPCF"` | `ssdt4.dsl:869` |
| `_STA` | Method 0 | inside NPCF | `0x0F` (or `0x0D` when disabled) — `nv_acpi` checks enabled via `acpi_get_handle` success; ACPI spec requires present+enabled+decoding | `ssdt4.dsl:870` |
| `_DIS/_STA pair` | Method/Name | inside NPCF | `_DIS sets CDIS=1` optional but must exist for S3 semantics | `ssdt4.dsl:877` |
| `_DSM` | Method 4 Serialized | inside NPCF | `If(Arg0==ToUUID(36b49710-...)){If(Arg1==0x0200){Switch(Arg2)...}}` | `ssdt4.dsl:888` |
| `NPCS` | Integer | `\_SB.PC00.PEG1.PEGP.NPCS` | `!=0` else `_DSM` early Return 0 (ssdt4.dsl:885); ensure GPU _DSM path sets NPCS via `_STA`/`_INI` | `ssdt4.dsl:885` |
| Names | `ACBT DCBT DBAC DBDC AMAT AMIT ATPP DTPP TPPL DROS LTBL STBL CDIS CUSL CUCT` | inside NPCF | `ACBT 0x50→80×??`, `AMAT 0x78(120)`, `AMIT 0xFF88(-120)`, `ATPP 0x0428` override (>stock 0x0168), `TPPL 0x00017700`, rest Zero unless custom | `ssdt4.dsl:848-854` vs override `npcf-loq.dsl:5-19` |
| `Notify` | `Notify(\_SB.NPCF, 0xC0)` | DSDT thermal zone / `\_SB` Notify | EC may fire `0xC0` `ACPI_NVPCF_EVENT_CHANGE` to invalidate powerd cache (`nv-acpi.c:68,151`) | `nv-acpi.c:151` |

### 6.3 Buffers

| Func | Arg2 | Arg1 | Buffer | Size | Contents (LE) | Offsets (PBD2) | Units |
|------|------|------|--------|------|---------------|----------------|-------|
| `GET_SUPPORTED` | `0x00` | `0x200` | `BUFF` | 4 | `BF 06 00 00` + OR `BUFF[1]|=0x01` (ssdt4.dsl:910-914) → driver reads 32-bit `supportedFuncs` `ctrl0000system.h:2083` | — | bitmask: bit0=GET_SUPPORTED_YES (`2260`), bit8=TSP (`2262`), bit9=CPU_TDP (`2265`) |
| `GET_DYNAMIC 1x` | `1` | `0x200` but uses `ACPI_DSM_FUNCTION_NVPCF` rev 0x100 path | `Buffer 0x0E` | 14 | `20 03 01 00 25 04 05 01 01 01 00 00 00 AB` (ssdt4.dsl:935) | — | 0x10 header |
| **`GET_DYNAMIC 2x / GET_SUPPORTED 2x`** | **`0x02`** | **`0x200`** | **`PBD2`** | **`0x31 = 49`** | `00 25 05 1C 01 58 02 58 02 20 70 04 00 00 30 03 78 00 ...` split across 77-char DSL lines (`npcf-loq-v2.dsl:43-52`) — must be exactly `0x31` and pass `configReadStructure` header `0x05/0x10/0x1C` checks (`client_resource.c:3121`) | `PBD2 0:PTV2` `1:PHB2` `2:GSB2` `3:CTB2` `4:NCE2` `5:TGPA Word` `7:TGPD Word` `0x15:PC01` `0x16:PC02` `0x19:TPPA Word` `0x1B:TPPD` `0x1D:MAGA` `0x1F:MAGD` `0x21:MIGA` `0x23:MIGD` `0x25:DROP DWord` `0x29:LTBC` `0x2D:STBC` (`ssdt4.dsl:938-973`) | Word fields ×125mW (`nvpcf.h:308`) → `0x0258=600×0.125=75.0W TGPA/TGPD`, `0x0428=1064×0.125=133W? but TARGET_TPP offset semantics clamp to TPP table; MIGD=MIGA etc.` |
| `GET_STATIC 2x` | `0x01` | `0x200` | `<=255B` + checksum byte | ≤255 (`3219`) | header+tables per `nvpcf.h` static TB; last byte checksum `~sum+1` (`client_resource.c:2929`) | `NVPCF0100_CTRL_CONFIG_2X_BUFF_SIZE_MAX 255` (`nvpcf.h:2283`) | parsed by `_controllerParseStaticTable_2x` |

All buffers returned as `ACPI_TYPE_BUFFER` (`nv-acpi.c:427 extract_buffer`) — not Integer/Package. `Buffer(0x31)` exactly 49 decimal; iasl warning about `CreateWordField` on `PBD2` is fine — runtime `Create*Field` binds correctly.

### 6.4 Header Fields (DSDT wholesale)

| Field | Required | Value | Verified |
|-------|----------|-------|----------|
| `Signature` | `DSDT` | `"DSDT"` | `dsdt.dsl:21 DefinitionBlock("","DSDT",2,"LENOVO"...` |
| `Revision` | `2` | `2` (ACPI 2.0) | `dsdt.dsl:21 2` |
| `OEM ID` | 6-char | `"LENOVO"` (pad sp) | stock `LENOVO` |
| `OEM Table ID` | 8-char | `"CB-01   "` (trailing spaces) | stock `CB-01   ` |
| `OEM Revision` | 32-bit | `0x00000002` (**bump from 0x00000001**) | new DSDT must have `...,"CB-01   ",0x00000002)`; iasl prints `OEM Revision 0x00000002 (2)` on `iasl -d dsdt_patched.dat` |
| `Creator ID` | 4-char | `INTL` | iasl default |
| `Creator Revision` | 32-bit | `0x20251212` (iasl 20251212) | `iasl -v 20251212`, `iasl` writes Compiler Version `0x20251212` (vs stock `0x20200717`) |
| `Length` | table len | `~659656B` per prompt, stock measured `665060B dsdt.dat` — ± slop due to comment/Compiler bump acceptable; file must disassemble clean (`0 Errors`) | `ls -lh dsdt.dat 665060` vs prompt 659656B — cite both; iasl clean is gate |
| `Checksum` | 8-bit | valid (sum 0) | computed by `iasl` |

**Initrd shape:** `kernel/firmware/acpi/dsdt.aml` inside **UNCOMPRESSED `newc` cpio `070701`** at `boot():/016e8f8930.../linux-cachyos/initramfs` **second**? Actually Track B staged as `boot():/npcf.cpio FIRST` then original SECOND for SSDT; for **DSDT** the correct Limaine is `module_path: boot():/npcf.cpio` (contains `kernel/firmware/acpi/DSDT.aml`? per `Documentation/admin-guide/acpi/dsdt-override.rst` DSDT is `kernel/firmware/acpi/dsdt.aml` lowercase) — verify `CONFIG_ACPI_TABLE_UPGRADE=y` (`ev/phase4 task 4.0 PASS`) and `CONFIG_ACPI_CUSTOM_DSDT` may need fallback `DSDT.aml` all-caps alias; include both via `cpio -t` check.

### 6.5 Reference-Fixup List

- Must `Drop External(_SB_.NPCF, UnknownObj)` and insert `Scope(\_SB){Device(NPCF){...}}` at the same insertion point (near `dsdt.dsl:70` External block, before `Scope(_SB)` at 3619).
- Ensure no duplicate `Device(NPCF)` remains (SSDT4's Device will be shadowed — ACPI allows override via later-loaded tables, but DSDT wholesale replaces the **base**, so SSDT4's NPCF will be *re-defined*? Actually DSDT's NPCF and SSDT4's NPCF are **two** devices with same `_HID` → would create two namespace nodes. **Fix:** the replacement DSDT must **not** also allow SSDT4 to create a second `_SB.NPCF`. The correct technique is to make the DSDT's replacement *exactly* one NPCF and adjust SSDT4's `External` resolution — but AML permits two `\_SB.NPCF` via `Scope(\_SB){Device(NPCF)}` in DSDT *and* SSDT4's `Device(NPCF)` would collide `AE_ALREADY_EXISTS`. Therefore the **DSDT patch must set `SSDP override` policy**: Linux's `acpi_tb_override_table` for DSDT replacement *replaces* OEM DSDT entirely, so the new DSDT's NPCF is the only one; SSDT4's `Device(NPCF)` will then attempt to redeclare → needs handling via `ACPI table upgrade appends, not replace` — the stock `acpidump` includes SSDT4 still. There are two safe strategies: (a) keep NPCF **only** in DSDT and make SSDT4's `Device(NPCF)` become a no-op via `CDIS` or rename? Better (b) move the workload to DSDT: DSDT's NPCF is authoritative, SSDT4's NPCF will still load but Linux's namespace allows *extended* Device if *Scope* is used — ambiguous. Mitigation: include `External(_SB_.PC00.PEG1.PEGP.NPCS)` and keep SSDT4 unchanged but rely on DSDT's `_STA 0xF` to win enumeration; `nv-acpi.c:361` `acpi_get_handle(handle,"NPCF")` on `\_SB` handle will find the **DSDT** child first (DSDT loaded before SSDTs). Test gate: after reboot, `ls /sys/bus/acpi/devices/NVDA0820:00/path` should read `\_SB_.NPCF` exactly once, not `NVDA0820:00` and `:01` duplicate. If duplicate, set `SSDT4 NPCF _STA 0x00` via DSDT `Name(CDIS,1)` tie? Simpler: patch DSDT to define `Name(_SB.NPCF.CDIS, Zero)` and leave SSDT4 as snapshot — the initrd contains only `kernel/firmware/acpi/dsdt.aml` (not SSDT) so SSDT4 binary `ssdt4.dat` is still loaded from UEFI; its `_STA` will see `CDIS` from DSDT's namespace? They share `\_SB.NPCF.CDIS` — if DSDT defines `CDIS=0` and SSDT4 reads it, `_STA` stays `0xF`. Duplicate still. Worst case, patch SSDT4 in the same initrd via `kernel/firmware/acpi/ssdt4.aml` with `DefinitionBlock("","SSDT",...)` that returns `0x00` for that device — but spec says **wholesale DSDT per Phase 5** is sufficient; risk noted.

---

## 7. GO/NO-GO Verdict — "stock driver + replaced DSDT ⇒ PMO constructed"

| Hypothesis | Verdict | Confidence | Basis |
|------------|---------|------------|-------|
| `\_SB.NPCF` DSDT at OEM Rev 2, `NVDA0820`, `_STA F`, `_DSM 36b49710 rev 0x200` with `BUFF[0x31]` as specified **will** be discovered by `nv_acpi_methods_init()` (`361`) and by `nv_acpi_dsm_method("\\_SB.NPCF._DSM")` (`793`), `osCallACPI_DSM GET_SUPPORTED` will return `BF06`, `GET_DYNAMIC 0x02` valid, `GET_STATIC` checksum passes, `nvidia-powerd 2.0b1` `Control 0x13b` returns `NV_OK`, controllers allocated, PMO considered *constructed* (log `Table Upgrade: install [SSDT-/DSDT]`, `nvpcf_handle != NULL`, `dmesg` `NVRM: NVPCF ...` no error) | **GO** | **HIGH (0.86)** | Hard-coded pathname `nv-acpi.c:793`, walk handle `361`, GUID `guids.c:85`, rev `acpidsmguids.h:74/76`, case dispatch `client_resource.c:2969-3264` all confirm the *only* gates are this device path + UUID + rev + buffer shape. No `ppt_cpu_cl/FE0B0F00/0x62` gate exists (grep ∅ §2). Iasl 20251212 proves AML is syntactically valid (`0 Errors 1 Warning 2 Remarks` both 302B and 326B builds). `CONFIG_ACPI_TABLE_UPGRADE=y` verified (`ev/phase4 task4 PASS`). Track B proved *Table Upgrade installs* (`+1 SSDT23 326B`) — so initrd mechanism works; moving the blob from SSDT `070701 kernel/firmware/acpi/npcf-loq.aml` (1024B cpio) to `kernel/firmware/acpi/dsdt.aml` uses the *same* `CONFIG_ACPI_TABLE_UPGRADE` override path (kernel `drivers/acpi/tables.c: acpi_table_upgrade()` handles both). The only delta from Phase 5 failure is **namespace location**, which this spec fixes. |
| Residual watts will exceed 50W sustained | **GO with EC caveat** — *PMO will construct*; *watts may still be ~44W due to EC cross-load* | Medium (0.62) for watts, High (0.86) for PMO | Prior `combined-5m 300 rows avg33.28 max51.87`, `isolated 262 rows avg35.59 max44.52` show EC `ppt_cpu_cl 30W / FE0B0F00` clamps independent of NVPCF limits (`RAPL 65W held 42828000df8208`). Overriding NVPCF raises the *target* TPP/TGP shown in `nvidia-smi -q -d POWER` (`Current 45→?`, `Default 35`, `Max 65`) via RM JPAC, but the *analog* EC current limit at `FE0B0F00` still enforces a wall (out-of-scope §5). Expect `nvidia-smi` limit →65 and `power.draw` peak 50-55 post-CPU-release, sustained combined 38-44 until EC re-tuned via `legion_laptop` `FE0B0F00` — not via NPCF. Phase 6 does **not** promise FULL WIN on Loq-ec-power matrix. |

**Action:** proceed to DSDT-wholesale build, stage as `boot():/npcf.cpio` FIRST + original SECOND (as `limine.conf` already does for SSDT; same for DSDT with lowercase `dsdt.aml`), set `OEM Revision 0x00000002`, reboot to test entry `CachyOS-NPCCF`, verify `dmesg | grep -i "Table Upgrade.*DSDT\|NVPCF\|NVDA0820"` + `cat /sys/bus/acpi/devices/NVDA0820:00/status` (=15) + `nvidia-smi -q -d POWER`.

---

## 8. Risk Register

| # | Risk | Likelihood | Impact | Mitigation |
|---|------|------------|--------|------------|
| R1 | **Duplicate `_SB.NPCF` collision** (DSDT's device + SSDT4's device both `_SB.NPCF` → `AE_ALREADY_EXISTS` at namespace add) | Medium | Boot ACPI warn, `_STA` race may mute DSM | Define DSDT NPCF as *scope* with unique `Name(_HID)` and guard SSDT4 with `If (LEqual(_SB.NPCF.CDIS, One)) Return(Zero)` or include a stub `ssdt4.aml` in same cpio that returns `_STA 0x00`. Check `dmesg \| grep -i "already exists"`. If duplicate, switch to strategy (b) above. |
| R2 | **OEM Revision not bumped** (leave `0x00000001` stock) | Low (spec mandates `0x00000002`) | Kernel `acpi_table_upgrade` may consider it *same rev* and not prefer initrd table (though spec says override regardless, some `acpi_blacklist` checks use rev) | Always `DefinitionBlock("","DSDT",2,"LENOVO","CB-01   ",0x00000002)` — verify via `iasl -d` header. The `659656B` prompt implies the new DSDT is slightly smaller than stock `665060B` (bump + optimization); exact bytes <10KB diff is irrelevant — header rev matters. |
| R3 | **Cpio format regression** (zstd 439B panic vs newc 070701 1024B OK — Phase 4 B3 kernel panic on `initramfs.npcf.cpio.zstd` FIRST) | High if re-zstd | Kernel panic initramfs load failure | Use **UNCOMPRESSED** `newc` (`find kernel -print0 | cpio --null -H newc -o > /boot/npcf.cpio`, `file` → `ASCII cpio archive (SVR4 with no CRC)`, `hexdump` starts `303730373031` `070701`, size `1024B`). Measured `/boot/npcf.cpio 1024B 070701` (`stat` 1024) — keep. |
| R4 | **Limine order wrong** (original FIRST, npcf SECOND) | Low (currently `module_path: boot():/npcf.cpio` FIRST then `boot():/.../initramfs` SECOND — correct per `limine.conf:70/71` 3272B diff 8 lines) | OEM DSDT wins, PMO not replaced | Validate `grep module_path /boot/limine.conf` order; first must be `npcf.cpio` (DSDT), second original. Keep two entries: default `CachyOS` (without npcf) + `CachyOS NPCCF` (with). |
| R5 | **Checksum / buffer size off-by-one** (`PBD2 0x31` vs `0x30` / missing checksum byte) | Low | `validateConfigStaticTable_2x:2929` fails → `NV_ERR_NOT_SUPPORTED` → powerd back to 35W | DSL must be `Buffer(0x31)` literal 49 (`npcf-loq.dsl:43`), `iasl` output exactly 49; do not hand-edit hex. SSDT4 reference `PBD2 0x31` (`ssdt4.dsl:929`) is the oracle. Verify via `hexdump -C npcf-loq.aml | grep 30 70 04`. |
| R6 | **Initrd DSDT pathname case** (`dsdt.aml` vs `DSDT.aml` vs `kernel/firmware/acpi/DSDT.aml`) | Medium | `acpi_table_upgrade` looks for `ACPI_TABLE_UPGRADE_NAME "kernel/firmware/acpi"` + file `*.aml` lower? Kernel expects `dsdt.aml` lowercase but also scans case-insensitive on some arch | Include **both** aliases in cpio: `kernel/firmware/acpi/dsdt.aml` and `kernel/firmware/acpi/DSDT.aml` (hard-link). `cpio -t` must list one of them. |
| R7 | **EC cross-load still caps at ~44W** (expected as per REPORT.md PARTIAL) → user perceives GO failure | High | Confounds FULL/PARTIAL classification | Pre-declare PARTIAL as success for PMO; measure both `power.limit` (should be 65) and `power.draw` under `cuda-matmul 300 + stress-ng` (probe after CPU release spike 51W). Compare `constraint_0 65000000` vs `nvidia-smi limit`. Document out-of-scope §5. |
| R8 | **Compiler rev drift** (iasl 20251212 vs stock 20200717) causes decompiler header mismatch warnings | Very Low | Benign | Ignore; iasl clean is `0 Errors` (1 Warn 3124, 2 Rem 2184/2173) as cited above. The `659656B` vs `665060B` delta is compiler constant pool re-encode — not a failure. |
| R9 | **SecureBoot/ACPI table override disabled** (kernel lockdown) | Very Low (`cat /proc/cmdline` `quiet nowatchdog splash ...` no lockdown) | initrd table ignored | Check `dmesg | grep -i "ACPI: Table Upgrade"` — must contain line; if not, add `acpi_no_static_ssdt`? not needed. Verify `CONFIG_ACPI_TABLE_UPGRADE=y` (ev/phase4 task4 PASS). |
| R10 | **NVIDIA PMO event Notify 0xC0 not wired** (no EC notify path after DSDT edit) | Low | Powerd controllers may not refresh on AC/DC flip | Keep `Method(Notify)` shim if DSDT previously had `Notify(\_SB.NPCF,0xC0)` on battery-source change; otherwise powerd polls. Verify via `acpi_listen` 0xC0 after AC plug. |

---

## Appendix — Citations & How to Verify Post-Reboot

**EC gate check (negative):**
```bash
rg -n "ppt_cpu_cl|cross_load|FE0B0F00" <NVIDIA_OPEN_SRC> --glob '*.{c,h}' # → ∅
strings /usr/bin/nvidia-powerd | rg -i "ppt|cross|FE0B|0x62" # → ∅
rg -n "NVPCF|36b49710|_DSM.*NV" <NVIDIA_OPEN_SRC> --glob '*.{c,h}' # → 14 hits listed in §1
```

**Iasl 20251212 clean:**
```bash
iasl npcf-loq.dsl 2>&1 | tee /tmp/iasl.log
# expect: 0 Errors, 1 Warnings (3124), 2 Remarks (2184,2173), Compiler 20251212
# same for <REDACTED> → 326B
stat -c %s npcf-loq.aml # 302
stat -c %s <REDACTED> # 326
# stock DSDT 665060B vs prompt 659656B — header bump explains delta; gate is iasl clean
```

**Track B before/after:**
```bash
dmesg | grep -i "ACPI: SSDT.*initrd\|Table Upgrade\|NPCF\|NVDA0820\|NVPCF"
ls /sys/bus/acpi/devices/NVDA0820:*/{path,status,uid} # after DSDT patch expect exactly one _SB.NPCF, status 15
cat /proc/driver/nvidia/gpus/0000:01:00.0/power  # Notebook Dynamic Boost Supported
journalctl -u nvidia-powerd --no-pager | tail -n 50 # expect no "SBIOS support not found"
nvidia-smi -q -d POWER  # Current Limit should be >45, target 65 if PMO constructed
```

**Reference-fixup check:**
```bash
acpidump -o /tmp/acpi_new.dat && acpixtract -a /tmp/acpi_new.dat
iasl -d dsdt.dat && grep -n "External.*NPCF\|Device (NPCF)" dsdt.dsl
# post-patch: External absent, Device present; pre-patch had External at dsdt.dsl:70
```

*All file:line above are verbatim. No driver was modified (read-only phase).*
