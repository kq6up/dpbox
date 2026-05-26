#!/bin/sh
# apply_new_patches.sh
# Applies new dpbox patches (patch-ba through patch-bg) as
# individual git commits and pushes each one to GitHub.
#
# Run from: /Users/chris/dpbox-6.00.00
# Usage: sh apply_new_patches.sh
#
# Bails out immediately if any step fails.
#
# Prerequisites:
#   - All pristine pkgsrc patches already applied and pushed
#   - New patch files in $NEW_PATCH_DIR

set -e

REPO_DIR="/Users/chris/dpbox-6.00.00"
NEW_PATCH_DIR="/Users/chris/pkgsrc/ham/dpbox/patches"

apply_and_commit() {
    PATCH_FILE=$1
    COMMIT_MSG=$2
    APPLY_DIR=$3   # "source" or "." relative to REPO_DIR

    echo ""
    echo "=========================================="
    echo "Applying: $(basename $PATCH_FILE)"
    echo "=========================================="

    # Check patch file exists
    if [ ! -f "$PATCH_FILE" ]; then
        echo "ERROR: Patch file not found: $PATCH_FILE"
        exit 1
    fi

    # Apply the patch
    cd "$REPO_DIR/$APPLY_DIR"
    if ! patch -p0 < "$PATCH_FILE"; then
        echo "ERROR: patch failed for $(basename $PATCH_FILE) - bailing out"
        exit 1
    fi

    # Stage all changes
    cd "$REPO_DIR"
    git add -A

    # Confirm something actually changed
    if git diff --cached --quiet; then
        echo "ERROR: No changes staged after applying $(basename $PATCH_FILE)"
        exit 1
    fi

    # Commit
    if ! git commit -m "$COMMIT_MSG"; then
        echo "ERROR: git commit failed - bailing out"
        exit 1
    fi

    # Push
    if ! git push; then
        echo "ERROR: git push failed - bailing out"
        exit 1
    fi

    echo "=== SUCCESS: $(basename $PATCH_FILE) applied, committed and pushed ==="
}

# -----------------------------------------------------------------------
# YOUR NEW PATCHES (patch-ba through patch-bg)
# 64-bit portability fixes and bug fixes not in original pkgsrc patches
# -----------------------------------------------------------------------

# patch-ba: Makefile -O0 workaround (split from pristine patch-aa)
apply_and_commit \
    "$NEW_PATCH_DIR/patch-ba" \
    "Workaround optimization crash: -O0 -g pending root cause investigation" \
    "source"

# patch-bb: WP/MYBBS %jd fixes (split from pristine patch-ay)
apply_and_commit \
    "$NEW_PATCH_DIR/patch-bb" \
    "Fix WP/MYBBS protocol crashes: %ld -> %jd for 64-bit long values in box_wp.c" \
    "source"

# patch-bc: DFree() integer overflow
apply_and_commit \
    "$NEW_PATCH_DIR/patch-bc" \
    "Fix DFree() integer overflow causing false DISK FULL on large filesystems" \
    "source"

# patch-bd: connect time display fix
apply_and_commit \
    "$NEW_PATCH_DIR/patch-bd" \
    "Fix stale clock in do_quit() causing wrong connect time display" \
    "source"

# patch-be: FHEADER buffer overflow
apply_and_commit \
    "$NEW_PATCH_DIR/patch-be" \
    "Fix ownfheader buffer overflow truncating FHEADER config value" \
    "source"

# patch-bf: IFACE_CMDBUF struct misalignment
apply_and_commit \
    "$NEW_PATCH_DIR/patch-bf" \
    "Fix IFACE_CMDBUF struct misalignment on 64-bit systems causing session hang" \
    "source"

# patch-bg: Huffman wire format
apply_and_commit \
    "$NEW_PATCH_DIR/patch-bg" \
    "Fix Huffman wire format size field: long -> int32_t fixes Decode-Error from 32-bit neighbors" \
    "source"

echo ""
echo "=========================================="
echo "ALL NEW PATCHES APPLIED SUCCESSFULLY"
echo ""
echo "Next steps:"
echo "  1. Test build on NetBSD with -O2 to check if crash is gone"
echo "     (if so, patch-ba can be removed)"
echo "  2. Write patch-bh (system CFLAGS / strip fix)"
echo "  3. Tag v6.1.0 and create GitHub Release:"
echo "     git tag v6.1.0"
echo "     git push origin v6.1.0"
echo "=========================================="
