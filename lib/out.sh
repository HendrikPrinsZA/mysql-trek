#!/bin/bash
#=======================================================================================================================
#
# FILE: out.sh
#
# DESCRIPTION: Logic for exporting database
#
#=======================================================================================================================

#=== FUNCTION ==========================================================================================================
# NAME          out_set_target
# DESCRIPTION   Handles the export's target directory
#=======================================================================================================================
out_set_target() {
   if [ "$G_TARGET" = "" ]; then
      G_TARGET="dumps/${G_DB_NAME}_"$(date +"%Y%m%d_%H%M%S")
   fi

   if [ ! "$G_FORCE_ON" = "y" ]; then
      echo "Target dump folder/file"
      G_TARGET=$(common_input_text "Location" "$G_TARGET")
   fi
   out_prepare_target
}

#=== FUNCTION ==========================================================================================================
# NAME          out_prepare_target
# DESCRIPTION   Prepares the export's target directory
#=======================================================================================================================
out_prepare_target() {
   G_TARGET_BASENAME=${G_TARGET##*/}
   G_TARGET_BASENAME_NO_EXT="$(echo $G_TARGET_BASENAME | cut -f 1 -d '.')"
   G_TARGET_PARENT_DIR=${G_TARGET%$G_TARGET_BASENAME}
   G_TARGET_DIR=${G_TARGET_PARENT_DIR}${G_TARGET_BASENAME_NO_EXT}

   # If target's parent directory does not exist: prompt to create
   if [ ! -d $G_TARGET_PARENT_DIR ]; then
      if [ ! $G_FORCE_ON = "y" ]; then
         read -p "Are you sure you want to create the target's parent directory '$G_TARGET_PARENT_DIR'? (y/n): " resp
         if [ "$resp" = "y" ]; then
            mkdir -p $G_TARGET_PARENT_DIR
         else
            out_set_target
         fi
      else
         mkdir -p $G_TARGET_PARENT_DIR
      fi
   fi

   # If the target directory exists: prompt to clear
   if [ -d $G_TARGET_DIR ]; then
      if [ ! $G_FORCE_ON = "y" ]; then
         read -p "Are your sure you want to clear the directory '$G_TARGET_DIR'? (y/n): " resp
         if [ "$resp" = "y" ]; then
            rm -rf ${G_TARGET_DIR}/*
         else
            out_set_target
         fi
      else
         rm -rf ${G_TARGET_DIR}/*
      fi
   fi

   # If the target file exists: prompt to overwrite
   if [ -f $G_TARGET ]; then
      if [ ! $G_FORCE_ON = "y" ]; then
         read -p "Are your sure you want to overwrite the target file '$G_TARGET'? (y/n): " resp
         if [ "$resp" = "y" ]; then
            rm -rf $G_TARGET
         else
            out_set_target
         fi
      else
         rm -rf $G_TARGET
      fi
   fi

   # If the target dir does not exist, create
   if [ ! -d $G_TARGET_DIR ]; then
      mkdir -p $G_TARGET_DIR
   fi
}

#=== FUNCTION ==========================================================================================================
# NAME          trek_out
# DESCRIPTION   Main export driver
#=======================================================================================================================
trek_out() {
    connect_test $G_DB_HOST $G_DB_USER $G_DB_PASS $G_DB_NAME
    out_set_target
    export_tables
    export_triggers
    export_views
    export_routines
    export_data
    archive_compress
}
