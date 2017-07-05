#! /bin/bash
set +x

LEEK_NAME=JeanFile

FOLDER=/home/Max/TUC-The-Code/
IA_NAME_1=GlobalVar
IA_FILE_NAME_1="${FOLDER}/${IA_NAME_1}"

IA_NAME_2=Utilitaires
IA_FILE_NAME_2="${FOLDER}/${IA_NAME_2}"

IA_NAME_3=Strategy
IA_FILE_NAME_3="${FOLDER}/${IA_NAME_3}"

IA_NAME_4=FonctionEtat
IA_FILE_NAME_4="${FOLDER}/${IA_NAME_4}"

IA_NAME_5=IA
IA_FILE_NAME_5="${FOLDER}/${IA_NAME_5}"

#--------------------------------------------------------------------------------------------------------------------------
function connect(){
echo -----------
echo Connexion

# requiert un fichier "pass" contenant (sans les guillements) "password=motdepasse" au format url. Par exemple pour "motdep@ss" il faut mettre "motdep%40ss"
# requiert un fichhier "login" contenant le login. Par exemple pour "toto" il faut mettre "toto" (sans les guillemets)
curl -i "https://leekwars.com/api/farmer/login" --data "@pass" \
						--data-urlencode "login@login" \
						2>/dev/null \
						> result_connection.log 

TOKEN=$(grep -oP 'token=.*?;' result_connection.log)
echo Token de la session :${TOKEN}

# extrait l'ID du poireau nommé $LEEK_NAME
LEEK_ID=$(grep -oP "\{.*\}" result_connection.log | jq ".farmer.leeks | map(select (.name == \"${LEEK_NAME}\"))[].id")
echo Leek name : ${LEEK_NAME}
echo Leek ID : ${LEEK_ID}
}



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



#--------------------------------------------------------------------------------------------------------------------------
function garden_fight(){
echo
echo ----------
echo Get adversary from Garden 
curl -i "https://leekwars.com/api/garden/get-leek-opponents/${LEEK_ID}/$" -H "Cookie: ${TOKEN}" 2>/dev/null > opponents.log

#extrait le json, récupère les opposants, les tri par ratio talent/level et extrait l'ID du premier (aka le plus faible)
ADVERSARY_ID=$(grep -oP "\{.*\}" opponents.log | jq '.opponents | sort_by(.talent/.level) | .[0].id')
#extrait le PHPSESSID nécessaire au lancement de la fight
PHPSESSID=$(grep -oP "PHPSESSID.*?;" opponents.log)

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


#--------------------------------------------------------------------------------------------------------------------------
function fight_analysis(){
# récupération des log du combat. Si le combat n'est pas encore finni on attend 1 seconde et on récupère les logs
curl "https://leekwars.com/api/fight/get/${FIGHT_ID}" > fight.log 2>/dev/null
if [ $(jq '.fight.status' fight.log) -ne 1 ]; then
	echo Fight non terminée : attente de 1 seconde
	sleep 1
	curl "https://leekwars.com/api/fight/get/${FIGHT_ID}" > fight.log 2>/dev/null
fi


if [ ! -z $(jq ".fight.leeks1[] | select(.name == \"${LEEK_NAME}\") | .name" fight.log) ]; then
WE_ARE_PLAYER_1=true
else
WE_ARE_PLAYER_1=false
fi
echo We are player 1 : ${WE_ARE_PLAYER_1}

echo 
# on vérifie  si le gagnant est le joueur 1 ou le joueur 2, et on regarde si le nom $LEEK_NAME est contenu dans ce joueur
if [ $(jq ".fight.winner" fight.log) -eq 1 ]; then
	WINNER_LEEK=$(jq ".fight.leeks1[] | select(.name == \"${LEEK_NAME}\") | .name" fight.log)
else
	WINNER_LEEK=$(jq ".fight.leeks2[] | select(.name == \"${LEEK_NAME}\") | .name" fight.log)
fi
if [ -z ${WINNER_LEEK} ]; then
	figlet Defeat -f big
	RESULT_FIGHT=defeat
else
	figlet Victory --gay -f big
	RESULT_FIGHT=victory
fi

P1_RECEIVED_DAMAGE=$(jq '.fight.data.actions[]|select(.[0] == 101 and .[1] == 0)[2]' fight.log | awk '{s+=$1} END {print s}')
if [[ -z ${P1_RECEIVED_DAMAGE} ]]; then P1_RECEIVED_DAMAGE=0; fi
P2_RECEIVED_DAMAGE=$(jq '.fight.data.actions[]|select(.[0] == 101 and .[1] == 1)[2]' fight.log | awk '{s+=$1} END {print s}')
if [[ -z ${P2_RECEIVED_DAMAGE} ]]; then P2_RECEIVED_DAMAGE=0; fi

P1_RECEIVED_HEAL=$(jq '.fight.data.actions[]|select(.[0] == 103 and .[1] == 0)[2]' fight.log | awk '{s+=$1} END {print s}')
if [[ -z ${P1_RECEIVED_HEAL} ]]; then P1_RECEIVED_HEAL=0; fi
P2_RECEIVED_HEAL=$(jq '.fight.data.actions[]|select(.[0] == 103 and .[1] == 1)[2]' fight.log | awk '{s+=$1} END {print s}')
if [[ -z ${P2_RECEIVED_HEAL} ]]; then P2_RECEIVED_HEAL=0; fi

echo Player 1 damage received : ${P1_RECEIVED_DAMAGE}
echo Player 1 heal  received : ${P1_RECEIVED_HEAL}
echo Player 2 damage received : ${P2_RECEIVED_DAMAGE}
echo Player 2 heal  received : ${P2_RECEIVED_HEAL}

#Inscription du résultat dans les logs des fights
if ${WE_ARE_PLAYER_1}; then

	echo logging
	echo ${FIGHT_ID} 	${RESULT_FIGHT}		$((${P1_RECEIVED_DAMAGE}-${P1_RECEIVED_HEAL})) 	$((${P2_RECEIVED_DAMAGE}-${P2_RECEIVED_HEAL}))>> fight_history.log
else
	echo logging
	echo ${FIGHT_ID} 	${RESULT_FIGHT}		$((${P2_RECEIVED_DAMAGE}-${P2_RECEIVED_HEAL})) 	$((${P1_RECEIVED_DAMAGE}-${P1_RECEIVED_HEAL}))>> fight_history.log
fi
}

#--------------------------------------------------------------------------------------------------------------------------
function disconnect(){
echo
echo 
echo -----------
echo Deconnexion
curl "https://leekwars.com/api/farmer/disconnect" -H "Cookie: ${TOKEN}" \
						--data "token="%"24" >/dev/null 2>&1 
}


connect
upload_code ${IA_NAME_1} ${IA_FILE_NAME_1}
upload_code ${IA_NAME_2} ${IA_FILE_NAME_2}
upload_code ${IA_NAME_3} ${IA_FILE_NAME_3}
upload_code ${IA_NAME_4} ${IA_FILE_NAME_4}
upload_code ${IA_NAME_5} ${IA_FILE_NAME_5}
disconnect
rm result_connection.log
