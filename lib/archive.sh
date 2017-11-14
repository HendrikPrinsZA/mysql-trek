#!/bin/bash
#=======================================================================================================================
#
# FILE: archive.sh
#
# DESCRIPTION: Compress and extract functionality
#
#=======================================================================================================================

#=== FUNCTION ==========================================================================================================
# NAME          archive_compress
# DESCRIPTION   Compress the target directory, after export
#=======================================================================================================================
archive_compress() {
    local startTimer=$(common_get_time_seconds)
    common_print "Archive" "..."

    if [ -f ${G_TARGET_DIR}.tar.gz ]; then
        rm ${G_TARGET_DIR}.tar.gz
    fi
    tar -zcf ${G_TARGET_DIR}.tar.gz ${G_TARGET_DIR}
    rm -rf ${G_TARGET_DIR}
    common_print "Archive" "$(common_get_duration $startTimer)" "\n"
}

#=== FUNCTION ==========================================================================================================
# NAME          archive_extract
# DESCRIPTION   Extracts the target file, before import
#=======================================================================================================================
archive_extract() {
    local startTimer=$(common_get_time_seconds)
    printf "\rUnarchive: \t..."
    
    if [ -f ${G_TARGET_DIR}.tar.gz ]; then
        rm ${G_TARGET_DIR}.tar.gz
    fi
    tar -zcf ${G_TARGET_DIR}.tar.gz ${G_TARGET_DIR}
    rm -rf ${G_TARGET_DIR}
    common_print "Unarchive" "$(common_get_duration $startTimer)" "\n"
}
