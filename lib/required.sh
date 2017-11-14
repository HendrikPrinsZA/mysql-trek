#!/bin/bash
#=======================================================================================================================
#
# FILE: required.sh
#
# DESCRIPTION: Deals with ensuring that all the prerequisites are satisfied
#
#=======================================================================================================================

#======================================================================
#  Requirements lookup
#======================================================================
G_REQ_MAP=(
    'mysql::MySQL command-line tool'
    'mysqldump::MySQL database backup program'
    'gzip::Compress or expand files'
    'tar::Creates and manipulates streaming archive files'
    'sed::Stream editor for filtering and transforming text'
    'awk::Pattern-directed scanning and processing language'
    'grep::File pattern searcher'
)

#=== FUNCTION ==========================================================================================================
# NAME          required_is_command_available
# DESCRIPTION   Checks if the command is available
#=======================================================================================================================
required_is_command_available() { # $1: command
   if ! res="$(type -p "$1")" || [ -z "$res" ]; then
      return 1
   else
      return 0
   fi
}

#=== FUNCTION ==========================================================================================================
# NAME          out_set_target
# DESCRIPTION   Handles the export's target directory
#=======================================================================================================================
required_check_all() {
    for index in "${G_REQ_MAP[@]}" ; do
        cmd="${index%%::*}"
        if ! required_is_command_available "$cmd"; then
            showHelp "The terminal command \`$cmd\` is not available, please install the related package it and ensure it is executable."
            exit 1
        fi
    done
}

#=== FUNCTION ==========================================================================================================
# NAME          out_set_target
# DESCRIPTION   Handles the export's target directory
#=======================================================================================================================
required_get_usage() {
   local required="Requirements\n";
   local indent="                         "
   for index in "${G_REQ_MAP[@]}" ; do
       cmd="${index%%::*}"
       description="${index##*::}"
       str="${indent}${description}"
       cmdLength=$((${#cmd}+2))
       str="${str:0:2}${cmd}${str:$cmdLength}"
       required="${required}${str}\n"
   done
   printf "$required"
}
