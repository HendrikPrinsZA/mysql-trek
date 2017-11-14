#!/bin/bash
#=======================================================================================================================
#
# FILE: connect.sh
#
# DESCRIPTION: Database export logic
#
#=======================================================================================================================

#=== FUNCTION ==========================================================================================================
# NAME          export_tables
# DESCRIPTION   Export the database's tables
#=======================================================================================================================
export_tables() {
    local startTimer=$(common_get_time_seconds)
    local dumpFilePath="${G_TARGET_DIR}/tables.sql"
    local mysqlOptions="--no-data --skip-triggers --compress --create-options $G_MYSQL_OPTIONS"
    local ignoreViewsArgs=$(connect_get_ignore_views)

    common_print "Tables" "..."

    if [ "$GZIP_ON" = "n" ]; then
        mysqldump --defaults-extra-file=${G_TMP_FILE} $mysqlOptions -h${G_DB_HOST} -u${G_DB_USER} ${G_DB_NAME} ${ignoreViewsArgs} | sed -E "s/DEFAULT CHARSET=[a-zA-Z0-9]*//g" > $dumpFilePath
    else
        mysqldump --defaults-extra-file=${G_TMP_FILE} $mysqlOptions -h${G_DB_HOST} -u${G_DB_USER} ${G_DB_NAME} ${ignoreViewsArgs} | sed -E "s/DEFAULT CHARSET=[a-zA-Z0-9]*//g" | gzip > "${dumpFilePath}.gz"
    fi

    common_print "Tables" "$(common_get_duration $startTimer)" "\n"
}

#=== FUNCTION ==========================================================================================================
# NAME          export_triggers
# DESCRIPTION   Export the database's triggers
#=======================================================================================================================
export_triggers() {
    local startTimer=$(common_get_time_seconds)
    local dumpFilePath="${G_TARGET_DIR}/triggers.sql"
    local mysqlOptions="--triggers --no-create-info --no-data --no-create-db $G_MYSQL_OPTIONS"

    common_print "Triggers" "..."

    if [ "$GZIP_ON" = "n" ]; then
        mysqldump --defaults-extra-file=${G_TMP_FILE} $mysqlOptions -h${G_DB_HOST} -u${G_DB_USER} ${G_DB_NAME} | sed -E 's/DEFINER=`[^`]+`@`[^`]+`//g' > $dumpFilePath
    else
        mysqldump --defaults-extra-file=${G_TMP_FILE} $mysqlOptions -h${G_DB_HOST} -u${G_DB_USER} ${G_DB_NAME} | sed -E 's/DEFINER=`[^`]+`@`[^`]+`//g' | gzip > "${dumpFilePath}.gz"
    fi

    common_print "Triggers" "$(common_get_duration $startTimer)" "\n"
}

#=== FUNCTION ==========================================================================================================
# NAME          export_views
# DESCRIPTION   Export the database's views
#=======================================================================================================================
export_views() {
    local startTimer=$(common_get_time_seconds)
    local dumpFilePath="${G_TARGET_DIR}/views.sql"

    common_print "Views" "..."

    echo 'SET FOREIGN_KEY_CHECKS=0; SET UNIQUE_CHECKS=0; ' > $dumpFilePath
    sql="SELECT CONCAT('DROP TABLE IF EXISTS ', TABLE_SCHEMA, '.', TABLE_NAME, '; CREATE OR REPLACE VIEW ', TABLE_SCHEMA, '.', TABLE_NAME, ' AS ', VIEW_DEFINITION, '; ') table_name from information_schema.views WHERE TABLE_SCHEMA LIKE '$DB_NAME'"
    mysql --defaults-extra-file=${G_TMP_FILE} -h${G_DB_HOST} -u${G_DB_USER} ${G_DB_NAME} --skip-column-names --batch -e "$sql" >> $dumpFilePath
    echo 'SET FOREIGN_KEY_CHECKS=1; SET UNIQUE_CHECKS=1; ' >> $dumpFilePath

    if [ "$GZIP_ON" = "y" ]; then
        gzip $dumpFilePath
    fi

    common_print "Views" "$(common_get_duration $startTimer)" "\n"
}

#=== FUNCTION ==========================================================================================================
# NAME          export_routines
# DESCRIPTION   Export the database's routines
#=======================================================================================================================
export_routines() {
    local startTimer=$(common_get_time_seconds)
    local dumpFilePath="${G_TARGET_DIR}/routines.sql"
    local mysqlOptions="--routines --skip-triggers --no-create-info --no-data --no-create-db $G_MYSQL_OPTIONS"

    common_print "Routines" "..."

    if [ "$GZIP_ON" = "n" ]; then
        mysqldump --defaults-extra-file=${G_TMP_FILE} $mysqlOptions -h${G_DB_HOST} -u${G_DB_USER} ${G_DB_NAME} | sed -E 's/DEFINER=`[^`]+`@`[^`]+`//g' > $dumpFilePath
    else
        mysqldump --defaults-extra-file=${G_TMP_FILE} $mysqlOptions -h${G_DB_HOST} -u${G_DB_USER} ${G_DB_NAME} | sed -E 's/DEFINER=`[^`]+`@`[^`]+`//g' | gzip > "${dumpFilePath}.gz"
    fi

    common_print "Routines" "$(common_get_duration $startTimer)" "\n"
}

#=== FUNCTION ==========================================================================================================
# NAME          export_data
# DESCRIPTION   Export the database's data in a separate file for every table
#=======================================================================================================================
export_data() {
    local startTimer=$(common_get_time_seconds)
    local tablesList=$(connect_get_table_list)
    local tablesTotal=$(connect_get_table_count)
    local counter=0
    local mysqlOptions="--quick --single-transaction --compress --no-create-info --skip-triggers --disable-keys --extended-insert $G_MYSQL_OPTIONS"
    local dumpDirPath="${G_TARGET_DIR}/data"

    common_print "Data" "..."

    if [ ! -d $dumpDirPath ]; then
        mkdir -p $dumpDirPath
    fi

    for table in $tablesList; do
        counter=$((counter+1))

        local dumpFilePath="$dumpDirPath/${table}.sql"

        if [ "$GZIP_ON" = "n" ]; then
            mysqldump --defaults-extra-file=${G_TMP_FILE} $mysqlOptions -h${G_DB_HOST} -u${G_DB_USER} ${G_DB_NAME} ${table} > $dumpFilePath
        else
            mysqldump --defaults-extra-file=${G_TMP_FILE} $mysqlOptions -h${G_DB_HOST} -u${G_DB_USER} ${G_DB_NAME} ${table} | gzip > "${dumpFilePath}.gz"
        fi

        common_print "Data" $(common_get_duration $startTimer) "[$counter/$tablesTotal]"
    done

    common_print "Data" $(common_get_duration $startTimer) "\n"
}
