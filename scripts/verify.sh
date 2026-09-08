#!/usr/bin/env bash
# verify.sh — Post-boot verification for LOQ NPCF ACPI override
#
# Run this after rebooting into the NPCCF entry to verify all patches took effect.
# Requires: sudo, acpi_call module, nvidia-smi

set -uo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

pass() { echo -e "  ${GREEN}PASS${NC} $1"; }
fail() { echo -e "  ${RED}FAIL${NC} $1"; FAILURES=$((FAILURES+1)); }
warn() { echo -e "  ${YELLOW}WARN${NC} $1"; }

FAILURES=0

echo "=== LOQ NPCF ACPI Override Verification ==="
echo ""

# 1. DSDT override loaded?
echo "[1] DSDT override from initrd"
if dmesg | grep -q "Table Upgrade: override \[DSDT-LENOVO-CB-01"; then
    pass "DSDT override loaded"
else
    fail "DSDT override NOT found in dmesg"
fi

# 2. SSDT overrides loaded?
SSDT_COUNT=$(dmesg | grep -c "Table Upgrade: override \[SSDT-LENOVO-CB-01" || true)
if [ "$SSDT_COUNT" -ge 20 ]; then
    pass "$SSDT_COUNT SSDT overrides loaded"
elif [ "$SSDT_COUNT" -gt 0 ]; then
    warn "Only $SSDT_COUNT SSDT overrides loaded (expected 22)"
else
    fail "No SSDT overrides found"
fi

# 3. Load acpi_call
echo ""
echo "[2] NPCF DSM functions"
sudo modprobe acpi_call 2>/dev/null

# 4. NPCF func0
RESULT=$(echo '\_SB.NPCF._DSM {0x10,0x97,0xb4,0x36,0x83,0x24,0xe7,0x11,0x95,0x98,0x08,0x00,0x20,0x0c,0x9a,0x66} 0x200 0x00 {0x00,0x00,0x00,0x00}' | sudo tee /proc/acpi/call > /dev/null && cat /proc/acpi/call)
if echo "$RESULT" | grep -q "0x07.*0x01"; then
    pass "NPCF func0: $RESULT"
else
    fail "NPCF func0 unexpected: $RESULT"
fi

# 5. GPS func0 via _DSM (rev 0x200)
echo ""
echo "[3] GPS DSM functions"
RESULT=$(echo '\_SB.PC00.PEG1.PEGP._DSM {0x01,0x2D,0x13,0xA3,0xDA,0x8C,0xBA,0x49,0xA5,0x2E,0xBC,0x9D,0x46,0xDF,0x6B,0x81} 0x200 0x00' | sudo tee /proc/acpi/call > /dev/null && cat /proc/acpi/call)
if echo "$RESULT" | grep -q "0x11"; then
    pass "GPS func0 (GETPPL bit set): $RESULT"
elif echo "$RESULT" | grep -q "0x80000002"; then
    fail "GPS func0: 0x80000002 (method not found or GPSS=0)"
elif echo "$RESULT" | grep -q "0x80000001"; then
    fail "GPS func0: 0x80000001 (GPSS guard blocking — remove GPSS guard from _DSM)"
else
    warn "GPS func0: $RESULT"
fi

# 6. GPS func0x24 GETPPL
RESULT=$(echo '\_SB.PC00.PEG1.PEGP._DSM {0x01,0x2D,0x13,0xA3,0xDA,0x8C,0xBA,0x49,0xA5,0x2E,0xBC,0x9D,0x46,0xDF,0x6B,0x81} 0x200 0x24' | sudo tee /proc/acpi/call > /dev/null && cat /proc/acpi/call)
if echo "$RESULT" | grep -q "0xc8.*0xaf"; then
    pass "GPS func0x24 GETPPL: $RESULT"
elif echo "$RESULT" | grep -q "0x80000002"; then
    fail "GPS func0x24: 0x80000002 (not implemented)"
else
    warn "GPS func0x24: $RESULT"
fi

# 7. nvidia-smi power
echo ""
echo "[4] Power state"
POWER=$(nvidia-smi -q -d POWER 2>/dev/null)
CURRENT=$(echo "$POWER" | grep "Current Power Limit" | head -1 | awk '{print $NF}')
MAX=$(echo "$POWER" | grep "Max Power Limit" | head -1 | awk '{print $NF}')
echo "  Current Power Limit: $CURRENT"
echo "  Max Power Limit: $MAX"

# 8. Temperature
TEMP=$(nvidia-smi -q -d TEMPERATURE 2>/dev/null)
GPU_TEMP=$(echo "$TEMP" | grep "GPU Current Temp" | awk '{print $NF}')
TARGET_TEMP=$(echo "$TEMP" | grep "GPU Target Temperature" | awk '{print $NF}')
echo ""
echo "[5] Temperature"
echo "  GPU Current: $GPU_TEMP"
echo "  GPU Target: $TARGET_TEMP"

# 9. PlatformRequestHandler errors
echo ""
echo "[6] PlatformRequestHandler"
PH_ERRORS=$(dmesg | grep -c "PlatformRequestHandler" || true)
if [ "$PH_ERRORS" -gt 0 ]; then
    warn "$PH_ERRORS PlatformRequestHandler errors (boot-time cosmetic,不影响 runtime)"
else
    pass "No PlatformRequestHandler errors"
fi

# 10. Touchpad
echo ""
echo "[7] Touchpad"
if cat /proc/bus/input/devices 2>/dev/null | grep -qi "elan"; then
    pass "ELAN touchpad detected"
else
    fail "ELAN touchpad NOT detected"
fi

# 11. nvidia-powerd
echo ""
echo "[8] nvidia-powerd"
if systemctl is-active --quiet nvidia-powerd 2>/dev/null; then
    pass "nvidia-powerd running"
else
    warn "nvidia-powerd not running"
fi

echo ""
echo "=== Summary ==="
if [ "$FAILURES" -eq 0 ]; then
    echo -e "${GREEN}All checks passed.${NC}"
else
    echo -e "${RED}$FAILURES check(s) failed.${NC}"
fi
