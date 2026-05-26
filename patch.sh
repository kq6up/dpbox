#!/bin/sh
# apply_pristine_patches.sh
# Applies existing pkgsrc patches (patch-aa through patch-az) as
# individual git commits and pushes each one to GitHub.
#
# Run from: /Users/chris/dpbox-6.00.00
# Usage: sh apply_pristine_patches.sh
#
# Bails out immediately if any step fails.

set -e

REPO_DIR="/Users/chris/dpbox-6.00.00"
PATCH_DIR="/Users/chris/pkgsrc/ham/dpbox/patches"

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
# EXISTING PKGSRC PATCHES (patch-aa through patch-az)
# Applied in logical groups, not strictly alphabetical
# -----------------------------------------------------------------------

# Makefile
apply_and_commit \
    "$PATCH_DIR/patch-aa" \
    "Makefile.netbsd: update version string and build flags for 6.00.00" \
    "source"

# Type correctness
apply_and_commit \
    "$PATCH_DIR/patch-ab" \
    "Fix box_timing2 parameter type: long -> time_t for correctness" \
    "source"

# Missing includes
apply_and_commit \
    "$PATCH_DIR/patch-ad" \
    "Fix missing #include <string.h> in md2md5.c" \
    "source"

apply_and_commit \
    "$PATCH_DIR/patch-ae" \
    "Fix missing #include <limits.h> and add DragonFly BSD guards in init.h" \
    "source"

# DragonFly BSD platform support
apply_and_commit \
    "$PATCH_DIR/patch-ac" \
    "Add DragonFly BSD platform support to filesys.h" \
    "source"

apply_and_commit \
    "$PATCH_DIR/patch-af" \
    "Add DragonFly BSD platform support to filesys.c" \
    "source"

apply_and_commit \
    "$PATCH_DIR/patch-ah" \
    "Add DragonFly BSD platform support to status.c" \
    "source"

apply_and_commit \
    "$PATCH_DIR/patch-ai" \
    "Add DragonFly BSD platform support to shell.c" \
    "source"

apply_and_commit \
    "$PATCH_DIR/patch-ak" \
    "Add DragonFly BSD platform support to pastrix.c" \
    "source"

apply_and_commit \
    "$PATCH_DIR/patch-al" \
    "Add DragonFly BSD platform support to init.h" \
    "source"

apply_and_commit \
    "$PATCH_DIR/patch-am" \
    "Add DragonFly BSD platform support to init.c" \
    "source"

apply_and_commit \
    "$PATCH_DIR/patch-an" \
    "Add DragonFly BSD version string to box_sys.c" \
    "source"

apply_and_commit \
    "$PATCH_DIR/patch-ap" \
    "Add DragonFly BSD platform support to main.c" \
    "source"

# Undefined behavior / correctness fixes
apply_and_commit \
    "$PATCH_DIR/patch-ag" \
    "Fix undefined behavior: sequence point bug in conv_string functions in pastrix.c" \
    "source"

apply_and_commit \
    "$PATCH_DIR/patch-ao" \
    "Fix undefined behavior: add (u_char) casts to ctype functions in box.c" \
    "source"

apply_and_commit \
    "$PATCH_DIR/patch-aq" \
    "Fix undefined behavior: (u_char) casts and stray semicolon in box_mem.c" \
    "source"

apply_and_commit \
    "$PATCH_DIR/patch-ar" \
    "Fix undefined behavior: add (u_char) casts to ctype functions in box_scan.c" \
    "source"

apply_and_commit \
    "$PATCH_DIR/patch-as" \
    "Fix undefined behavior: add (u_char) casts to ctype functions in box_sf.c" \
    "source"

apply_and_commit \
    "$PATCH_DIR/patch-at" \
    "Fix undefined behavior: add (u_char) casts to ctype functions in box_sub.c" \
    "source"

apply_and_commit \
    "$PATCH_DIR/patch-au" \
    "Fix undefined behavior: add (u_char) casts to ctype functions in crawler.c" \
    "source"

apply_and_commit \
    "$PATCH_DIR/patch-av" \
    "Fix undefined behavior: add (u_char) casts to ctype functions in dpputlinks.c" \
    "source"

apply_and_commit \
    "$PATCH_DIR/patch-aw" \
    "Fix undefined behavior: add (u_char) casts to ctype functions in yapp.c" \
    "source"

apply_and_commit \
    "$PATCH_DIR/patch-ax" \
    "Fix undefined behavior: add (u_char) casts to ctype functions in dpgate.c" \
    "source"

apply_and_commit \
    "$PATCH_DIR/patch-ay" \
    "Fix undefined behavior: add (u_char) casts to ctype functions in box_wp.c" \
    "source"

apply_and_commit \
    "$PATCH_DIR/patch-az" \
    "Fix undefined behavior: add (u_char) casts to ctype functions in box_rout.c" \
    "source"

echo ""
echo "=========================================="
echo "ALL PRISTINE PKGSRC PATCHES APPLIED"
echo "Ready for your new patches (patch-ba onwards)"
echo "=========================================="
