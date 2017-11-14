#!/bin/bash
#=======================================================================================================================
#
# FILE: common.sh
#
# DESCRIPTION: Common helper functions
#
#=======================================================================================================================

#=== FUNCTION ==========================================================================================================
# NAME          common_print
# DESCRIPTION   Prints a message that overwrites itself
# PARAMETER 1   Title
# PARAMETER 2   Progress - usually time
# PARAMETER 3   Additional info (optional)
#=======================================================================================================================
common_print() {
   local block="                 "
   local title=$1
   local progress=$2
   local info=$3
   str="\r${title}:${block:${#title}}${progress}${block:${#progress}}${info}${block:${#info}}"
   printf "$str"
}

#=== FUNCTION ==========================================================================================================
# NAME          common_input_text
# DESCRIPTION   Prompts the user for an input value
# PARAMETER 1   Prompt
# PARAMETER 2   Default value (optional)
#=======================================================================================================================
common_input_text() {
   local value=''
   local promt='Enter value'
   local default=''

   if [ ! "$1" = "" ]; then
      prompt=$1
   fi

   if [ ! "$2" = "" ]; then
      default=$2
      prompt="$prompt ('$default')"
   fi

   if [ $G_FORCE_ON = "y" ] && [ ! $default = "" ] ; then
      echo $default
   else
      prompt="  $prompt: "
      read -p "$prompt" value
      if [ "$value" = "" ]; then
         value=$default
      fi
      echo $value
   fi
}

#=== FUNCTION ==========================================================================================================
# NAME          common_input_secret
# DESCRIPTION   Prompts the user for a secret input value (ex. password)
# PARAMETER 1   Prompt
# PARAMETER 2   Default value (optional)
#=======================================================================================================================
common_input_secret() {
   local value=''
   local promt='Enter value'
   local default=''

   if [ ! "$1" = "" ]; then
      prompt=$1
   fi

   if [ ! "$2" = "" ]; then
      default=$2
      prompt="$prompt ('********')"
   fi

   if [ $G_FORCE_ON = "y" ] && [ ! $default = "" ] ; then
      echo $default
   else
      prompt="  $prompt: "
      read -p "$prompt" -s value
      if [ "$value" = "" ]; then
         value=$default
      fi
      echo $value
   fi
}

#=== FUNCTION ==========================================================================================================
# NAME          common_seconds_to_time
# DESCRIPTION   Displays seconds in time format (H:i:s)
# PARAMETER 1   Seconds (integer)
#=======================================================================================================================
common_seconds_to_time() {
    ((h=${1}/3600))
    ((m=(${1}%3600)/60))
    ((s=${1}%60))
    printf "%02d:%02d:%02d\n" $h $m $s
}

#=== FUNCTION ==========================================================================================================
# NAME          common_get_time_seconds
# DESCRIPTION   Returns the current time in seconds
#=======================================================================================================================
common_get_time_seconds() {
    echo `date +%s`
}

#=== FUNCTION ==========================================================================================================
# NAME          common_seconds_to_time
# DESCRIPTION   Returns the acount of time since the start time
# PARAMETER 1   Start time (in seconds)
#=======================================================================================================================
common_get_duration() {
   local endTimer=$(common_get_time_seconds)
   echo "$(common_get_time_difference $1 $endTimer)"
}

#=== FUNCTION ==========================================================================================================
# NAME          common_get_time_difference
# DESCRIPTION   Returns the time differece between to times
# PARAMETER 1   Start time (in seconds)
# PARAMETER 1   End time (in seconds)
#=======================================================================================================================
common_get_time_difference() {
   echo "$(common_seconds_to_time `expr $2 - $1`)"
}
