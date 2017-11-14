#!/bin/bash
#=======================================================================================================================
#
# FILE: mysql-trek.sh
#
# USAGE: ./mysql-trek.sh [in|out] [options]
#
# DESCRIPTION: MySQL single database migration tool
#
# OPTIONS: see function show_help below
# REQUIREMENTS: [see 'lib/required.sh']
# BUGS: ---
# NOTES: ---
# AUTHOR: HF Prinsloo <info@hendrikprinsloo.co.za>
# VERSION: 0.0.1
# CREATED: 2017-11-10
#=======================================================================================================================

#-----------------------------------------------------------------------------------------------------------------------
# Includes
#-----------------------------------------------------------------------------------------------------------------------
CURRENT_DIR="$(pwd)"
. "$CURRENT_DIR/lib/globals.sh"
. "$CURRENT_DIR/lib/required.sh"
. "$CURRENT_DIR/lib/common.sh"
. "$CURRENT_DIR/lib/connect.sh"
. "$CURRENT_DIR/lib/in.sh"
. "$CURRENT_DIR/lib/export.sh"
. "$CURRENT_DIR/lib/out.sh"
. "$CURRENT_DIR/lib/archive.sh"


#=== FUNCTION ==========================================================================================================
# NAME          usage
# DESCRIPTION   Display usage information for this script.
# PARAMETER 1   Error string (optional)
#=======================================================================================================================
usage() {
    local required=$(required_get_usage)
    local errorString=""

    if [ ! "$1" = "" ]; then
        errorString="\nError: $1 \n\n"
        echo "!!! ERROR !!!"
        echo $1
        echo "[see help below]"
        printf "\n"
    fi

    echo "" | cat <<- EOT
MySQL Trek v0.0.1
Usage: ./mysql-trek.sh [in|out] [options]

       ./mysql-trek.sh out -h localhost -u root -p password123 -d db_one
       ./mysql-trek.sh in  -h localhost -u root -p password123 -d db_two -t dumps/db_one_20141101_120856

MySQL options
  -h, --host             Connect to MySQL server on given host
  -u, --user             MySQL user name to use when connecting to server
  -p, --password         Password to use when connecting to server
  -d, --database         The database to use

Other options
  -t, -f, --target       The location of the file/folder to use for the import/export
                         (i) Default: dumps/db_one_20141101_120856
  --gzip                 Enable gzip compression on the fly to limit disk space
  --force                Accept any confirmation dialogs
  --help                 Show this help section

$(printf "$required")
EOT
    exit
}

#-----------------------------------------------------------------------------------------------------------------------
# Parse command line arguments
#-----------------------------------------------------------------------------------------------------------------------
while true; do
    case "$1" in
        -h | --host )
            G_DB_HOST=$2
            shift; shift; continue;;
        -h* | --host* )
            G_DB_HOST=$(echo $1 | sed -E 's/(--host=|--host|-h=|-h)//g')
            shift;;

        -u | --user )
            G_DB_USER=$2
            shift; shift;;
        -u* | --user* )
            G_DB_USER=$(echo $1 | sed -E 's/(--user=|--user|-u=|-u)//g')
            shift;;

        -p | --pass )
            G_DB_PASS=$2
            shift; shift;;
        -p* | --pass* )
            G_DB_PASS=$(echo $1 | sed -E 's/(--pass=|--pass|-p=|-p)//g')
            shift;;

        -d | --name | --database )
            G_DB_NAME=$2
            shift; shift;;
        -d* | --name* | --database* )
            G_DB_NAME=$(echo $1 | sed -E 's/(--database=|--database|--name=|--name|-d=|-d)//g')
            shift;;

        -t | -f | --target )
            G_TARGET=$2
            shift; shift;;
        -t* | -f* | --target* )
            G_TARGET=$(echo $1 | sed -E 's/(--target=|--target|-t=|-t|-f=|-f)//g')
            shift;;

        -y | --force )
            G_FORCE_ON="y"
            shift;;

        --gzip )
            G_GZIP_ON="y"
            shift;;

        --help )
            usage
            exit 0;;

        * )
            if [ "$1" = "out" ] || [ "$1" = "in" ] ; then
                G_IN_OR_OUT=$1
                shift;
                continue;
            fi

            # Set db name if not already set
            if [ "$G_DB_NAME" = "" ]; then
                G_DB_NAME=$1
            fi

            if [ ! "$1" = "" ]; then
                usage "Invalid argument '$1'"
            fi

            break;;
    esac
done

#-----------------------------------------------------------------------------------------------------------------------
# Drive application
#-----------------------------------------------------------------------------------------------------------------------
required_check_all

if [ ! "$G_IN_OR_OUT" = "out" ] && [ ! "$G_IN_OR_OUT" = "in" ] ; then
    usage "Expected the first argument to be 'in' or 'out'."
fi

if [ "$G_IN_OR_OUT" = "out" ]; then
    trek_out
fi

if [ "$G_IN_OR_OUT" = "in" ]; then
    trek_in
fi
