#! /bin/bash

function connect(){
echo -----------
echo Connexion


curl -i "https://leekwars.com/api/farmer/login" \
							--data "keep_connected=false" \
							--data "@$VAR_PATH/pass" \
							--data-urlencode "login@$VAR_PATH/login" \
							2>/dev/null \
							> $LOG_PATH/result_connection.log

TOKEN=$(grep -oP 'token=.*?;' $LOG_PATH/result_connection.log)
echo Token de la session :${TOKEN}

# extrait l'ID du poireau nommé $LEEK_NAME
LEEK_ID=$(grep -oP "\{.*\}" $LOG_PATH/result_connection.log | jq ".farmer.leeks | map(select (.name == \"${LEEK_NAME}\"))[].id")
echo Leek name : ${LEEK_NAME}
echo Leek ID : ${LEEK_ID}
}
