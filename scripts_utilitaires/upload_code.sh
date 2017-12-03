#! /bin/bash
set +x

COMMAND_PATH=$(dirname $0)
VAR_PATH=$COMMAND_PATH/var
LOG_PATH=$COMMAND_PATH/log
BIN_PATH=$COMMAND_PATH/bin

source $BIN_PATH/connect.sh
source $BIN_PATH/disconnect.sh
source $BIN_PATH/upload_code.sh

#--------------------------------------------------------------------------------------------------------------------------
# Parameters of the script  

LEEK_NAME=JeanFile
IA_PATH=$COMMAND_PATH/../IA/	


IA_NAME_1=GlobalVar
IA_FILE_NAME_1="${IA_PATH}/${IA_NAME_1}"

IA_NAME_2=util_misc
IA_FILE_NAME_2="${IA_PATH}/${IA_NAME_2}"

IA_NAME_3=util_can_use
IA_FILE_NAME_3="${IA_PATH}/${IA_NAME_3}"

IA_NAME_4=util_score
IA_FILE_NAME_4="${IA_PATH}/${IA_NAME_4}"

IA_NAME_5=util_filters
IA_FILE_NAME_5="${IA_PATH}/${IA_NAME_5}"

IA_NAME_6=util_combos
IA_FILE_NAME_6="${IA_PATH}/${IA_NAME_6}"

IA_NAME_7=Strategy
IA_FILE_NAME_7="${IA_PATH}/${IA_NAME_7}"

IA_NAME_8=FonctionEtat
IA_FILE_NAME_8="${IA_PATH}/${IA_NAME_8}"

IA_NAME_9=IA
IA_FILE_NAME_9="${IA_PATH}/${IA_NAME_9}"


connect

upload_code ${IA_NAME_1} ${IA_FILE_NAME_1}
upload_code ${IA_NAME_2} ${IA_FILE_NAME_2}
upload_code ${IA_NAME_3} ${IA_FILE_NAME_3}
upload_code ${IA_NAME_4} ${IA_FILE_NAME_4}
upload_code ${IA_NAME_5} ${IA_FILE_NAME_5}
upload_code ${IA_NAME_6} ${IA_FILE_NAME_6}
upload_code ${IA_NAME_7} ${IA_FILE_NAME_7}
upload_code ${IA_NAME_8} ${IA_FILE_NAME_8}
upload_code ${IA_NAME_9} ${IA_FILE_NAME_9}

disconnect
