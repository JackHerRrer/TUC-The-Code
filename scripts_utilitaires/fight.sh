! /bin/bash
set +x

LEEK_NAME=JeanFile
IA_NAME=IA

RESULT_FIGHT=

#--------------------------------------------------------------------------------------------------------------------------
function connect(){
echo -----------
echo Connexion


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

function upload_code(){
echo
echo -----------
echo get ID of IA named $IA_NAME
IA_ID=$(curl "https://leekwars.com/api/ai/get-farmer-ais/$" -H "Cookie: ${TOKEN}"  \
							--data "token="%"24" \
							2>/dev/null \
	| jq ".ais | map(select(.name == \"${IA_NAME}\") | .id)" \
	| grep -oP "\d*")

echo IA_ID $IA_ID

echo
echo ----------
echo Charge code 

curl "https://leekwars.com/api/ai/save/" -H "Cookie: ${TOKEN}"  \
					--data "ai_id=${IA_ID}" \
					--data "token="%"24" \
					--data-urlencode "code@code.ls"
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
# récupération des log du combat. Si le combat n'est pas encore finni on attend 1 seconde (60 secondes max) et on récupère les logs
curl "https://leekwars.com/api/fight/get/${FIGHT_ID}" > fight.log 2>/dev/null
ITERATION=0
while [ $(jq '.fight.status' fight.log) -ne 1 ]; do
        echo Fight non terminée : attente de 1 seconde
       	sleep 1
	curl "https://leekwars.com/api/fight/get/${FIGHT_ID}" > fight.log 2>/dev/null
	ITERATION=$((${ITERATION} + 1))
	if [ ${ITERATION} -eq 60 ]; then
		echo "Cannot get the fight report in less than 60 secondes"
		exit 1
	fi
done 


if [ ! -z $(jq ".fight.leeks1[] | select(.name == \"${LEEK_NAME}\") | .name" fight.log) ]; then
WE_ARE_PLAYER_1=true
else
WE_ARE_PLAYER_1=false
fi
echo We are player 1 : ${WE_ARE_PLAYER_1}

echo 
if [ $(jq ".fight.winner" fight.log) -eq 0 ]; then
	#figlet "Tie" -f big
        RESULT_FIGHT="tie"
else
	# on vérifie  si le gagnant est le joueur 1 ou le joueur 2, et on regarde si le nom $LEEK_NAME est contenu dans ce joueur
	if [ $(jq ".fight.winner" fight.log) -eq 1 ]; then
		WINNER_LEEK=$(jq ".fight.leeks1[] | select(.name == \"${LEEK_NAME}\") | .name" fight.log)
	else
		WINNER_LEEK=$(jq ".fight.leeks2[] | select(.name == \"${LEEK_NAME}\") | .name" fight.log)
	fi
	if [ -z ${WINNER_LEEK} ]; then
		 #figlet Defeat -f big
		RESULT_FIGHT=defeat
	else
		#figlet Victory --gay -f big
		RESULT_FIGHT=victory
	fi
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

	echo logging result in fight_history.log
	echo ${FIGHT_ID} 	${RESULT_FIGHT}		$((${P1_RECEIVED_DAMAGE}-${P1_RECEIVED_HEAL})) 	$((${P2_RECEIVED_DAMAGE}-${P2_RECEIVED_HEAL}))>> fight_history.log
else
	echo logging result in fight_history.log
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

NBR_FIGHT=$1
connect
#upload_code
clear
for ((i = 0; i < $NBR_FIGHT; i++ )); do
     	tput sc
	printf "\n["
        for ((j = 0; j < $i; j++)); do
                printf "="
        done
        printf ">"

        for ((j = $i; j < $NBR_FIGHT; j++)); do
                printf " "
        done
        
	printf "] %d / %d\n" "$i" "$NBR_FIGHT"

	if [ "$RESULT_FIGHT" == "tie" ]; then
		#echo Tie
		figlet "Tie             " -f big
	elif [ "$RESULT_FIGHT" == "victory" ]; then
                #echo Victory
		figlet "Victory         " --gay -f big
        elif [ "$RESULT_FIGHT" == "defeat" ]; then
                #echo Defeat
		figlet "Defeat          " -f big
	else 
		echo Begining 
	fi 
	
	echo
	echo
    garden_fight
    fight_analysis
    tput rc
	
done

clear
if [ "$RESULT_FIGHT" == "tie" ]; then
        #echo Tie
        figlet "Tie             " -f big
elif [ "$RESULT_FIGHT" == "victory" ]; then
        #echo Victory
        figlet "Victory         " --gay -f big
elif [ "$RESULT_FIGHT" == "defeat" ]; then
        #echo Defeat
        figlet "Defeat          " -f big
else
        echo Begining
fi
echo
echo

disconnect

echo victory :
tail -n ${NBR_FIGHT} fight_history.log | grep victory | wc -l
echo tie :
tail -n ${NBR_FIGHT} fight_history.log | grep tie | wc -l
echo defeat :
tail -n ${NBR_FIGHT} fight_history.log | grep defeat | wc -l
