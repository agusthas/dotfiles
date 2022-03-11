#!/bin/sh

SCRIPT_LOG=$SCRIPT_DIR/logs/installer-script.log
[ -d $SCRIPT_DIR/logs ] || mkdir $SCRIPT_DIR/logs
[ -f $SCRIPT_LOG ] || touch $SCRIPT_LOG


# Prints warning/error $MESSAGE in red foreground color
#
# For e.g. You can use the convention of using RED color for [E]rror messages
function error_echo() {
    echo -e "\x1b[1;31m[E] $SELF_NAME: $1\e[0m"
}

function simple_error_echo() {
    echo -e "\x1b[1;31m$1\e[0m"
}

# Prints success/info $MESSAGE in green foreground color
#
# For e.g. You can use the convention of using GREEN color for [S]uccess messages
function success_echo() {
    echo -e "\x1b[1;32m[S] $SELF_NAME: $1\e[0m"
}

function simple_success_echo() {
    echo -e "\x1b[1;32m$1\e[0m"
}

# Prints $MESSAGE in blue foreground color
#
# For e.g. You can use the convetion of using BLUE color for [I]nfo messages
# that require special user attention (especially when script requires input from user to continue)
function info_echo() {
    echo -e "\x1b[1;34m[I] $SELF_NAME: $1\e[0m"
}

function simple_info_echo() {
    echo -e "\x1b[1;34m$1\e[0m"
}

function SCRIPTENTRY() {
  timeAndDate=`date`
  script_name=`basename "$0"`
  script_name="${script_name%.*}"
  echo "[$timeAndDate] [DEBUG]  > $script_name $FUNCNAME" >> $SCRIPT_LOG
}

function SCRIPTEXIT() {
  script_name=`basename "$0"`
  script_name="${script_name%.*}"
  echo "[$timeAndDate] [DEBUG]  < $script_name $FUNCNAME" >> $SCRIPT_LOG
}

function ENTRY() {
  local cfn="${FUNCNAME[1]}"
  timeAndDate=`date`
  echo "[$timeAndDate] [DEBUG]  > $cfn $FUNCNAME" >> $SCRIPT_LOG
}

function EXIT() {
  local cfn="${FUNCNAME[1]}"
  timeAndDate=`date`
  echo "[$timeAndDate] [DEBUG]  < $cfn $FUNCNAME" >> $SCRIPT_LOG
}


function INFO() {
  local function_name="${FUNCNAME[1]}"
  local msg="$1"
  timeAndDate=`date`
  echo "[$timeAndDate] [INFO]  $msg" >> $SCRIPT_LOG
  info_echo "$msg"
}


function DEBUG() {
  local function_name="${FUNCNAME[1]}"
  local msg="$1"
  timeAndDate=`date`
  echo "[$timeAndDate] [DEBUG]  $msg" >> $SCRIPT_LOG
  info_echo "$msg"
}

function ERROR() {
  local function_name="${FUNCNAME[1]}"
  local msg="$1"
  timeAndDate=`date`
  echo "[$timeAndDate] [ERROR]  $msg" >> $SCRIPT_LOG
  error_echo "$msg"
}
