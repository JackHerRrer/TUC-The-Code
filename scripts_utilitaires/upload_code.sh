#! /bin/bash
set +x

COMMAND_PATH=$(dirname $0)
VAR_PATH=$COMMAND_PATH/var
LOG_PATH=$COMMAND_PATH/log
BIN_PATH=$COMMAND_PATH/bin
MD5_PATH=$COMMAND_PATH/IA.md5

source $BIN_PATH/connect.sh
source $BIN_PATH/disconnect.sh
source $BIN_PATH/upload_code.sh

#--------------------------------------------------------------------------------------------------------------------------
# Parameters of the script  

LEEK_NAME=JeanFile
IA_PATH=$COMMAND_PATH/../IA	


IA_NAME_1=GlobalVar
IA_FILE_NAME_1="${IA_PATH}/${IA_NAME_1}"
IA_NEW_MD5_1=$(md5sum ${IA_PATH}/${IA_NAME_1} | awk '{print $1}')
IA_OLD_MD5_1=$(grep ${IA_NAME_1} ${MD5_PATH} 2>/dev/null | awk '{print $1}')

IA_NAME_2=util_misc
IA_FILE_NAME_2="${IA_PATH}/${IA_NAME_2}"
IA_NEW_MD5_2=$(md5sum ${IA_PATH}/${IA_NAME_2} | awk '{print $1}')
IA_OLD_MD5_2=$(grep ${IA_NAME_2} ${MD5_PATH} 2>/dev/null | awk '{print $1}')

IA_NAME_3=util_can_use
IA_FILE_NAME_3="${IA_PATH}/${IA_NAME_3}"
IA_NEW_MD5_3=$(md5sum ${IA_PATH}/${IA_NAME_3} | awk '{print $1}')
IA_OLD_MD5_3=$(grep ${IA_NAME_3} ${MD5_PATH} 2>/dev/null | awk '{print $1}')

IA_NAME_4=util_score
IA_FILE_NAME_4="${IA_PATH}/${IA_NAME_4}"
IA_NEW_MD5_4=$(md5sum ${IA_PATH}/${IA_NAME_4} | awk '{print $1}')
IA_OLD_MD5_4=$(grep ${IA_NAME_4} ${MD5_PATH} 2>/dev/null | awk '{print $1}')

IA_NAME_5=util_filters
IA_FILE_NAME_5="${IA_PATH}/${IA_NAME_5}"
IA_NEW_MD5_5=$(md5sum ${IA_PATH}/${IA_NAME_5} | awk '{print $1}')
IA_OLD_MD5_5=$(grep ${IA_NAME_5} ${MD5_PATH} 2>/dev/null | awk '{print $1}')

IA_NAME_6=util_combos
IA_FILE_NAME_6="${IA_PATH}/${IA_NAME_6}"
IA_NEW_MD5_6=$(md5sum ${IA_PATH}/${IA_NAME_6} | awk '{print $1}')
IA_OLD_MD5_6=$(grep ${IA_NAME_6} ${MD5_PATH} 2>/dev/null | awk '{print $1}')

IA_NAME_7=Strategy
IA_FILE_NAME_7="${IA_PATH}/${IA_NAME_7}"
IA_NEW_MD5_7=$(md5sum ${IA_PATH}/${IA_NAME_7} | awk '{print $1}')
IA_OLD_MD5_7=$(grep ${IA_NAME_7} ${MD5_PATH} 2>/dev/null | awk '{print $1}')

IA_NAME_8=FonctionEtat
IA_FILE_NAME_8="${IA_PATH}/${IA_NAME_8}"
IA_NEW_MD5_8=$(md5sum ${IA_PATH}/${IA_NAME_8} | awk '{print $1}')
IA_OLD_MD5_8=$(grep ${IA_NAME_8} ${MD5_PATH} 2>/dev/null | awk '{print $1}')

IA_NAME_9=IA_main
IA_FILE_NAME_9="${IA_PATH}/${IA_NAME_9}"
IA_NEW_MD5_9=$(md5sum ${IA_PATH}/${IA_NAME_9} | awk '{print $1}')
IA_OLD_MD5_9=$(grep ${IA_NAME_9} ${MD5_PATH} 2>/dev/null | awk '{print $1}')

connect

echo
if [ ! "${IA_NEW_MD5_1}" = "${IA_OLD_MD5_1}" ]; then upload_code ${IA_NAME_1} ${IA_FILE_NAME_1}; else echo "${IA_NAME_1} already uploaded"; fi
if [ ! "${IA_NEW_MD5_2}" = "${IA_OLD_MD5_2}" ]; then upload_code ${IA_NAME_2} ${IA_FILE_NAME_2}; else echo "${IA_NAME_2} already uploaded"; fi
if [ ! "${IA_NEW_MD5_3}" = "${IA_OLD_MD5_3}" ]; then upload_code ${IA_NAME_3} ${IA_FILE_NAME_3}; else echo "${IA_NAME_3} already uploaded"; fi
if [ ! "${IA_NEW_MD5_4}" = "${IA_OLD_MD5_4}" ]; then upload_code ${IA_NAME_4} ${IA_FILE_NAME_4}; else echo "${IA_NAME_4} already uploaded"; fi
if [ ! "${IA_NEW_MD5_5}" = "${IA_OLD_MD5_5}" ]; then upload_code ${IA_NAME_5} ${IA_FILE_NAME_5}; else echo "${IA_NAME_5} already uploaded"; fi
if [ ! "${IA_NEW_MD5_6}" = "${IA_OLD_MD5_6}" ]; then upload_code ${IA_NAME_6} ${IA_FILE_NAME_6}; else echo "${IA_NAME_6} already uploaded"; fi
if [ ! "${IA_NEW_MD5_7}" = "${IA_OLD_MD5_7}" ]; then upload_code ${IA_NAME_7} ${IA_FILE_NAME_7}; else echo "${IA_NAME_7} already uploaded"; fi
if [ ! "${IA_NEW_MD5_8}" = "${IA_OLD_MD5_8}" ]; then upload_code ${IA_NAME_8} ${IA_FILE_NAME_8}; else echo "${IA_NAME_8} already uploaded"; fi
if [ ! "${IA_NEW_MD5_9}" = "${IA_OLD_MD5_9}" ]; then upload_code ${IA_NAME_9} ${IA_FILE_NAME_9}; else echo "${IA_NAME_9} already uploaded"; fi

disconnect

md5sum ${IA_PATH}/* > ${MD5_PATH}
