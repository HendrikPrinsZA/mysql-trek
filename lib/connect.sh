#!/bin/bash
#=======================================================================================================================
#
# FILE: connect.sh
#
# DESCRIPTION: Handles database connection
#
#=======================================================================================================================

#=== FUNCTION ==========================================================================================================
# NAME          connect_test
# DESCRIPTION   Tests the database connection based on the current variables
# PARAMETER 1   Database host
# PARAMETER 2   Database user
# PARAMETER 3   Database password
# PARAMETER 4   Database name (optional) - If not passed, ignore database
#=======================================================================================================================
connect_test() {
    local includeDatabase="n"
    if [ -z ${4+x} ]; then includeDatabase="y"; fi

    if [ ! $G_CONN_STATUS = "failed" ] && [ ! $1 = "" ] && [ ! $2 = "" ] && [ ! $3 = "" ] ; then
        connect_verify $@
        return
    fi

    echo "Database connection"
    G_DB_HOST=$(captureInputText "Host" "$1")
    G_DB_USER=$(captureInputText "User" "$2")
    G_DB_PASS=$(captureInputSecret "Password" "$3")
    printf "\n"
    G_DB_NAME=$(captureInputText "Database" "$4")

    if [ $includeDatabase = "y" ]; then
        connect_verify $G_DB_HOST $G_DB_USER $G_DB_PASS $G_DB_NAME
    else
        connect_verify $G_DB_HOST $G_DB_USER $G_DB_PASS
    fi
}

#=== FUNCTION ==========================================================================================================
# NAME          connect_verify
# DESCRIPTION   Verify the connection credentials
# PARAMETER 1   Database host
# PARAMETER 2   Database user
# PARAMETER 3   Database password
# PARAMETER 4   Database name (optional) - If not passed, ignore database
#=======================================================================================================================
connect_verify() {
    local includeDatabase="n"
    if [ -z ${4+x} ]; then includeDatabase="y"; fi

    echo exit | mysql --host=$1 --user=$2 --password=$3 $4 -B 2>/dev/null
    if [ "$?" -gt 0 ]; then
        if [ $FORCE_ON = "y" ]; then
            usage "Connection failed (mysql --host=$1 --user=$2 --password=******* $4)"
        else
            echo "Error: Connection failed (mysql --host=$1 --user=$2 --password=******* $4)"
            G_CONN_STATUS="failed"
            connect_test $@
        fi
    else
        connect_save_tmp
    fi
}

#=== FUNCTION ==========================================================================================================
# NAME          connect_save_tmp
# DESCRIPTION   Saves the password in the temp file
#=======================================================================================================================
connect_save_tmp() {
    cat <<EOT > $G_TMP_FILE
[client]
password="${G_DB_PASS}"
EOT
}

#=== FUNCTION ==========================================================================================================
# NAME          connect_get_ignore_views
# DESCRIPTION   Get a string of '--ignore-table=X' arguments
#=======================================================================================================================
connect_get_ignore_views() {
    local res=""
    local sql="SELECT GROUP_CONCAT(CONCAT('--ignore-table=', TABLE_SCHEMA, '.', TABLE_NAME)  SEPARATOR ' ') AS 'res' FROM \
               information_schema.TABLES WHERE TABLE_TYPE LIKE 'VIEW' AND TABLE_SCHEMA = '$G_DB_NAME';"
    res=$(mysql --defaults-extra-file=${G_TMP_FILE} -h$G_DB_HOST -u$G_DB_USER $G_DB_NAME -s -N -e "$sql")
    if [ "$res" = "" ] || [ -z "$res" ] || [ "$res" = "NULL" ]; then
        echo ""
    else
        echo $res
    fi
}

#=== FUNCTION ==========================================================================================================
# NAME          connect_get_table_list
# DESCRIPTION   Get a list of all the tables to iterate
#=======================================================================================================================
connect_get_table_list() {
    local rows=$(mysql --defaults-extra-file=${G_TMP_FILE} -h$G_DB_HOST -u$G_DB_USER $G_DB_NAME -e "SHOW FULL TABLES WHERE Table_type <> 'VIEW'" | awk '{ print $1}' | grep -v '^Tables' )
    echo $rows
}

#=== FUNCTION ==========================================================================================================
# NAME          connect_get_table_count
# DESCRIPTION   Get the total number of tables
#=======================================================================================================================
connect_get_table_count() {
    local tables=$(connect_get_table_list)
    local counter=0
    for table in $tables; do
        counter=$((counter+1))
    done
    echo $counter
}
