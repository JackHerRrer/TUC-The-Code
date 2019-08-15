#! /bin/bash

function garden_fight(){
echo
echo ----------
echo Get adversary from Garden 
curl -i "https://leekwars.com/api/garden/get-leek-opponents/${LEEK_ID}" \
 	-H "Cookie: ${TOKEN}" \
	-H "Authorization: Bearer $"\
	2>/dev/null > $LOG_PATH/opponents.log

#extrait le json, récupère les opposants, les tri par ratio level/talent et extrait l'ID du premier (aka le plus fort)
ADVERSARY_ID=$(grep -oP "\{.*\}" $LOG_PATH/opponents.log | jq '.opponents | sort_by(.level/.talent) | .[0].id')
#extrait le PHPSESSID nécessaire au lancement de la fight
PHPSESSID=$(grep -oP "PHPSESSID.*?;" $LOG_PATH/opponents.log |sed 's/PHPSESSID=//' | tr -d ';')

echo PHPSESSID : ${PHPSESSID}
echo adversary ID : ${ADVERSARY_ID}

FIGHT_ID=$(curl -v "https://leekwars.com/api/garden/start-solo-fight" \
		-H "Cookie: ${TOKEN} PHPSESSID=${PHPSESSID}" \
		-H "Authorization: Bearer $"\
		--data "leek_id=${LEEK_ID}" \
		--data "target_id=${ADVERSARY_ID}" \
		2>/dev/null \
	| jq '.fight')

echo Fight ID : ${FIGHT_ID}
}
