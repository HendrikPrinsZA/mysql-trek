#!/bin/bash
#=======================================================================================================================
#
# FILE: in.sh
#
# DESCRIPTION: Logic for importing database
#
#=======================================================================================================================

#=== FUNCTION ==========================================================================================================
# NAME          trek_in
# DESCRIPTION   Main import driver
#=======================================================================================================================
trek_in() {
    connect_test $DB_HOST $DB_USER $DB_PASS # $DB_NAME
}