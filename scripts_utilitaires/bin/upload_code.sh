#! /bin/bash

#--------------------------------------------------------------------------------------------------------------------------
#upload le code 
#utilisation : upload_code $IA_NAME $IA_FILE_NAME 
function upload_code(){
echo
echo -----------
echo upload du fichier : $1
echo get ID
IA_ID=$(curl "https://leekwars.com/api/ai/get-farmer-ais/$" -H "Cookie: ${TOKEN}"  \
							--data "token="%"24" \
							2>/dev/null \
	| jq ".ais | map(select(.name == \"$1\") | .id)" \
	| grep -oP "\d*")

echo IA_ID $IA_ID

echo Charge code 

RESULT_UPLOAD=$(curl "https://leekwars.com/api/ai/save/" -H "Cookie: ${TOKEN}"  \
					--data "ai_id=${IA_ID}" \
					--data "token="%"24" \
					--data-urlencode "code@$2"\
					2>/dev/null)

if [[ -z $(echo ${RESULT_UPLOAD} | jq 'select(.result[][2] != 1)' ) ]]; then
        echo -e "\033[32msuccess\033[0m"
else
        echo -e "\033[31m${RESULT_UPLOAD}\033[0m"
fi

}