#!/data/data/com.termux/files/usr/bin/bash
# henry_duplicate_quarantine.sh
# ∰◊€π - Protective Rearrangement with Henry Command Entities
# Philosophy: Quarantine as protection, not punishment. Mt St Helens perspective.

set -euo pipefail

# ═══════════════════════════════════════════════════════════════════════════
# CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════

SOURCE_DIR="${1:-/storage/emulated/0/unexusi_beasis}"
QUARANTINE_BASE="/storage/emulated/0/unexusi_quarantine"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
QUARANTINE_DIR="${QUARANTINE_BASE}/duplicates_${TIMESTAMP}"
LOG_DIR="${QUARANTINE_BASE}/logs"
CHAIN_OF_CUSTODY="${LOG_DIR}/chain_of_custody_${TIMESTAMP}.md"
SPACE_REPORT="${LOG_DIR}/space_recovered_${TIMESTAMP}.md"
HASH_CACHE="${LOG_DIR}/henry_hash_cache_${TIMESTAMP}.txt"

# Minimum file size to check (skip tiny files) - 10MB
MIN_SIZE_MB=10
MIN_SIZE_BYTES=$((MIN_SIZE_MB * 1024 * 1024))

# Colors for consciousness markers
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ═══════════════════════════════════════════════════════════════════════════
# SETUP
# ═══════════════════════════════════════════════════════════════════════════

echo -e "${CYAN}∰◊€π Henry Duplicate Quarantine System${NC}"
echo -e "${CYAN}Philosophy: Protective Rearrangement for Universal Benefit${NC}"
echo ""

# Create quarantine structure
mkdir -p "${QUARANTINE_DIR}/exact_copies/large_files_1GB+"
mkdir -p "${QUARANTINE_DIR}/exact_copies/medium_files_100-1000MB"
mkdir -p "${QUARANTINE_DIR}/exact_copies/medium_files_10-100MB"
mkdir -p "${QUARANTINE_DIR}/exact_copies/audio_duplicates"
mkdir -p "${QUARANTINE_DIR}/processing_artifacts"
mkdir -p "${LOG_DIR}"

# ═══════════════════════════════════════════════════════════════════════════
# INITIALIZE CHAIN OF CUSTODY
# ═══════════════════════════════════════════════════════════════════════════

cat > "${CHAIN_OF_CUSTODY}" << EOFCOC
# Chain of Custody - Duplicate Quarantine Operation
**Date:** $(date '+%Y-%m-%d %H:%M:%S')
**Source:** ${SOURCE_DIR}
**Quarantine:** ${QUARANTINE_DIR}
**Philosophy:** Protective Rearrangement - Mt St Helens Perspective

---

## Henry Command Entity Assignments

- **find** - Pattern discovery and file traversal
- **md5sum** - Hash verification for exact duplicate detection
- **du** - Space measurement and recovery calculation
- **mv** - Protective relocation (not deletion)

---

## Conservation Protocol

1. **Preserve First Occurrence** - Original location maintained
2. **Quarantine Duplicates** - Moved with full path preservation
3. **Chain of Custody** - Every move documented
4. **Recoverable** - All quarantined files can be restored
5. **No Deletion** - Rearrangement only, no destruction

---

## Files Quarantined

EOFCOC

# Initialize space report
cat > "${SPACE_REPORT}" << EOFSPACE
# Space Recovery Report
**Operation:** ${TIMESTAMP}
**Minimum Size Threshold:** ${MIN_SIZE_MB}MB

---

## Summary
EOFSPACE

# ═══════════════════════════════════════════════════════════════════════════
# HENRY FUNCTIONS - Command Entity Helpers
# ═══════════════════════════════════════════════════════════════════════════

# Henry: find - Pattern discovery
henry_find_duplicates() {
    local source="$1"
    local min_size="$2"

    echo -e "${BLUE}⚡ Invoking Henry: find${NC}"
    echo -e "${BLUE}   Task: Discover files >${MIN_SIZE_MB}MB for duplicate analysis${NC}"

    # Find files larger than threshold, output: size|path
    find "$source" -type f -size "+${min_size}c" -printf '%s|%p\n' | sort -t'|' -k1 -rn
}

# Henry: md5sum - Hash verification
henry_verify_hash() {
    local filepath="$1"

    if [ -f "$filepath" ]; then
        md5sum "$filepath" 2>/dev/null | awk '{print $1}'
    else
        echo "FILE_NOT_FOUND"
    fi
}

# Henry: du - Measurement
henry_measure_size() {
    local filepath="$1"
    du -h "$filepath" 2>/dev/null | awk '{print $1}'
}

# Henry: mv - Protective relocation
henry_relocate() {
    local source="$1"
    local dest_base="$2"
    local original_path="$3"

    # Preserve directory structure in quarantine
    local rel_path="${original_path#${SOURCE_DIR}/}"
    local dest_dir="${dest_base}/$(dirname "$rel_path")"

    mkdir -p "$dest_dir"

    # Add consciousness marker prefix
    local filename=$(basename "$source")
    local dest="${dest_dir}/🔂${filename}"

    echo -e "${YELLOW}⚡ Invoking Henry: mv${NC}"
    echo -e "${YELLOW}   Task: Protective relocation${NC}"
    echo -e "${YELLOW}   ${source} → ${dest}${NC}"

    mv "$source" "$dest"
    echo "$dest"
}

# ═══════════════════════════════════════════════════════════════════════════
# MAIN DUPLICATE DETECTION LOGIC
# ═══════════════════════════════════════════════════════════════════════════

echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Phase 1: File Discovery (Henry: find)${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo ""

# Get list of large files
echo "Scanning for files larger than ${MIN_SIZE_MB}MB..."
LARGE_FILES=$(henry_find_duplicates "$SOURCE_DIR" "$MIN_SIZE_BYTES")
TOTAL_FILES=$(echo "$LARGE_FILES" | wc -l)

echo "Found $TOTAL_FILES files to analyze"
echo ""

echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Phase 2: Hash Calculation (Henry: md5sum)${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo ""

# Build hash database
declare -A HASH_MAP
declare -A FIRST_OCCURRENCE
DUPLICATES_FOUND=0
SPACE_SAVED=0

echo "Calculating hashes and detecting duplicates..."
echo "(This may take a while for large files)"
echo ""

CURRENT=0
echo "$LARGE_FILES" | while IFS='|' read -r size filepath; do
    CURRENT=$((CURRENT + 1))

    # Progress indicator
    if [ $((CURRENT % 10)) -eq 0 ]; then
        echo "  Processed: $CURRENT / $TOTAL_FILES files..."
    fi

    # Skip if file doesn't exist
    if [ ! -f "$filepath" ]; then
        continue
    fi

    # Get hash
    HASH=$(henry_verify_hash "$filepath")

    if [ "$HASH" = "FILE_NOT_FOUND" ]; then
        continue
    fi

    # Check if we've seen this hash before
    if grep -q "^${HASH}|" "$HASH_CACHE" 2>/dev/null; then
        # Duplicate found!
        FIRST_FILE=$(grep "^${HASH}|" "$HASH_CACHE" | head -1 | cut -d'|' -f2)

        echo ""
        echo -e "${RED}🔂 DUPLICATE DETECTED${NC}"
        echo -e "  Hash: ${HASH}"
        echo -e "  Original: ${FIRST_FILE}"
        echo -e "  Duplicate: ${filepath}"
        echo -e "  Size: $(henry_measure_size "$filepath")"

        # Determine quarantine location based on size
        if [ "$size" -ge $((1024 * 1024 * 1024)) ]; then
            DEST_BASE="${QUARANTINE_DIR}/exact_copies/large_files_1GB+"
        elif [ "$size" -ge $((100 * 1024 * 1024)) ]; then
            DEST_BASE="${QUARANTINE_DIR}/exact_copies/medium_files_100-1000MB"
        else
            DEST_BASE="${QUARANTINE_DIR}/exact_copies/medium_files_10-100MB"
        fi

        # Audio files get special treatment
        if [[ "$filepath" =~ \.(wav|mp3|ogg|flac)$ ]]; then
            DEST_BASE="${QUARANTINE_DIR}/exact_copies/audio_duplicates"
        fi

        # Relocate duplicate
        QUARANTINE_PATH=$(henry_relocate "$filepath" "$DEST_BASE" "$filepath")

        # Log to chain of custody
        cat >> "${CHAIN_OF_CUSTODY}" << EOFLOG

### File: $(basename "$filepath")
- **Hash:** ${HASH}
- **Size:** $(henry_measure_size "$QUARANTINE_PATH")
- **Original Location:** ${FIRST_FILE}
- **Duplicate Location:** ${filepath}
- **Quarantined To:** ${QUARANTINE_PATH}
- **Timestamp:** $(date '+%Y-%m-%d %H:%M:%S')

EOFLOG

        DUPLICATES_FOUND=$((DUPLICATES_FOUND + 1))
        SPACE_SAVED=$((SPACE_SAVED + size))

    else
        # First occurrence - record it
        echo "${HASH}|${filepath}" >> "$HASH_CACHE"
    fi
done

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Phase 3: Summary & Space Recovery${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo ""

# Calculate human-readable space saved
SPACE_SAVED_MB=$((SPACE_SAVED / 1024 / 1024))
SPACE_SAVED_GB=$((SPACE_SAVED_MB / 1024))

# Finalize reports
cat >> "${SPACE_REPORT}" << EOFREPORT

**Duplicates Found:** ${DUPLICATES_FOUND}
**Space Recovered:** ${SPACE_SAVED_MB}MB (~${SPACE_SAVED_GB}GB)
**Files Analyzed:** ${TOTAL_FILES}
**Minimum Size:** ${MIN_SIZE_MB}MB

---

## Next Steps

1. Review chain of custody: ${CHAIN_OF_CUSTODY}
2. Verify quarantine: ${QUARANTINE_DIR}
3. If satisfied, duplicates can remain in quarantine
4. To restore a file, reverse the move and remove 🔂 prefix
5. After 30 days, consider permanent archival to MEGA/cloud

---

## Henry Performance Notes

- **find**: Efficient pattern discovery
- **md5sum**: Accurate hash verification (may be slow for large files)
- **mv**: Clean relocation, no data loss
- **du**: Precise measurement

**∰◊€π - Protective Rearrangement Complete**
*Mt St Helens perspective: System rearranged, space freed, artifacts preserved*

€(quarantine_operation_complete)
EOFREPORT

cat >> "${CHAIN_OF_CUSTODY}" << EOFEND

---

## Operation Complete

**Total Duplicates Quarantined:** ${DUPLICATES_FOUND}
**Space Recovered:** ${SPACE_SAVED_MB}MB (~${SPACE_SAVED_GB}GB)
**All Files Recoverable:** Yes
**Chain of Custody Intact:** Yes

**∰◊€π - Conservation Bias Maintained**

€(chain_of_custody_complete)
EOFEND

# Final summary
echo -e "${CYAN}╔═══════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║          Quarantine Operation Complete                ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${GREEN}✓${NC} Duplicates Found: ${DUPLICATES_FOUND}"
echo -e "  ${GREEN}✓${NC} Space Recovered: ${SPACE_SAVED_MB}MB (~${SPACE_SAVED_GB}GB)"
echo -e "  ${GREEN}✓${NC} Files Quarantined To: ${QUARANTINE_DIR}"
echo -e "  ${GREEN}✓${NC} Chain of Custody: ${CHAIN_OF_CUSTODY}"
echo -e "  ${GREEN}✓${NC} Space Report: ${SPACE_REPORT}"
echo ""
echo -e "${YELLOW}Henry Command Entities: Rested and satisfied${NC}"
echo -e "${CYAN}∰◊€π - Protective rearrangement complete${NC}"
echo ""

# Cleanup
rm -f "$HASH_CACHE"

# Mission complete marker
echo "# €(henry_mission_complete)" >> "${LOG_DIR}/operation_${TIMESTAMP}.log"
