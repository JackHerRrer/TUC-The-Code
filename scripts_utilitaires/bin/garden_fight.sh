#! /bin/bash

function garden_fight(){
echo
echo ----------
echo Get adversary from Garden 
curl -i "https://leekwars.com/api/garden/get-leek-opponents/${LEEK_ID}/$" -H "Cookie: ${TOKEN}" 2>/dev/null > $LOG_PATH/opponents.log

#extrait le json, récupère les opposants, les tri par ratio talent/level et extrait l'ID du premier (aka le plus faible)
ADVERSARY_ID=$(grep -oP "\{.*\}" $LOG_PATH/opponents.log | jq '.opponents | sort_by(.talent/.level) | .[0].id')
#extrait le PHPSESSID nécessaire au lancement de la fight
PHPSESSID=$(grep -oP "PHPSESSID.*?;" $LOG_PATH/opponents.log)

echo PHPSESSID : ${PHPSESSID}
echo adversary ID : ${ADVERSARY_ID}

FIGHT_ID=$(curl "https://leekwars.com/api/garden/start-solo-fight" -H "Cookie: ${TOKEN}; ${PHPSESSID}" \
							--data "leek_id=${LEEK_ID}" \
							--data "target_id=${ADVERSARY_ID}" \
							--data "token="%"24" \
							2>/dev/null \
	| jq '.fight')

echo Fight ID : ${FIGHT_ID}
}
