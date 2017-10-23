#! /bin/bash

RESULT_FIGHT=

function fight_analysis(){
sleep 0.5
# récupération des log du combat. Si le combat n'est pas encore finni on attend 1 seconde (60 secondes max) et on récupère les logs
curl "https://leekwars.com/api/fight/get/${FIGHT_ID}" > $LOG_PATH/fight.log 2>/dev/null
ITERATION=0
while [ $(jq '.fight.status' $LOG_PATH/fight.log) -ne 1 ]; do
        echo Fight non terminée : attente de 1 seconde
       	sleep 1
	curl "https://leekwars.com/api/fight/get/${FIGHT_ID}" > $LOG_PATH/fight.log 2>/dev/null
	ITERATION=$((${ITERATION} + 1))
	if [ ${ITERATION} -eq 60 ]; then
		echo "Cannot get the fight report in less than 60 secondes"
		exit 1
	fi
done 


if [ ! -z $(jq ".fight.leeks1[] | select(.name == \"${LEEK_NAME}\") | .name" $LOG_PATH/fight.log) ]; then
WE_ARE_PLAYER_1=true
else
WE_ARE_PLAYER_1=false
fi
echo We are player 1 : ${WE_ARE_PLAYER_1}

echo 
if [ $(jq ".fight.winner" $LOG_PATH/fight.log) -eq 0 ]; then
	#figlet "Tie" -f big
        RESULT_FIGHT="tie"
else
	# on vérifie  si le gagnant est le joueur 1 ou le joueur 2, et on regarde si le nom $LEEK_NAME est contenu dans ce joueur
	if [ $(jq ".fight.winner" $LOG_PATH/fight.log) -eq 1 ]; then
		WINNER_LEEK=$(jq ".fight.leeks1[] | select(.name == \"${LEEK_NAME}\") | .name" $LOG_PATH/fight.log)
	else
		WINNER_LEEK=$(jq ".fight.leeks2[] | select(.name == \"${LEEK_NAME}\") | .name" $LOG_PATH/fight.log)
	fi
	if [ -z ${WINNER_LEEK} ]; then
		 #figlet Defeat -f big
		RESULT_FIGHT=defeat
	else
		#figlet Victory --gay -f big
		RESULT_FIGHT=victory
	fi
fi

P1_RECEIVED_DAMAGE=$(jq '.fight.data.actions[]|select(.[0] == 101 and .[1] == 0)[2]' $LOG_PATH/fight.log | awk '{s+=$1} END {print s}')
if [[ -z ${P1_RECEIVED_DAMAGE} ]]; then P1_RECEIVED_DAMAGE=0; fi
P2_RECEIVED_DAMAGE=$(jq '.fight.data.actions[]|select(.[0] == 101 and .[1] == 1)[2]' $LOG_PATH/fight.log | awk '{s+=$1} END {print s}')
if [[ -z ${P2_RECEIVED_DAMAGE} ]]; then P2_RECEIVED_DAMAGE=0; fi

P1_RECEIVED_HEAL=$(jq '.fight.data.actions[]|select(.[0] == 103 and .[1] == 0)[2]' $LOG_PATH/fight.log | awk '{s+=$1} END {print s}')
if [[ -z ${P1_RECEIVED_HEAL} ]]; then P1_RECEIVED_HEAL=0; fi
P2_RECEIVED_HEAL=$(jq '.fight.data.actions[]|select(.[0] == 103 and .[1] == 1)[2]' $LOG_PATH/fight.log | awk '{s+=$1} END {print s}')
if [[ -z ${P2_RECEIVED_HEAL} ]]; then P2_RECEIVED_HEAL=0; fi

echo Player 1 damage received : ${P1_RECEIVED_DAMAGE}
echo Player 1 heal  received : ${P1_RECEIVED_HEAL}
echo Player 2 damage received : ${P2_RECEIVED_DAMAGE}
echo Player 2 heal  received : ${P2_RECEIVED_HEAL}

#Inscription du résultat dans les logs des fights
if ${WE_ARE_PLAYER_1}; then

	echo logging result in $LOG_PATH/fight_history.log
	echo ${FIGHT_ID} 	${RESULT_FIGHT}		$((${P1_RECEIVED_DAMAGE}-${P1_RECEIVED_HEAL})) 	$((${P2_RECEIVED_DAMAGE}-${P2_RECEIVED_HEAL}))>> $LOG_PATH/fight_history.log
else
	echo logging result in $LOG_PATH/fight_history.log
	echo ${FIGHT_ID} 	${RESULT_FIGHT}		$((${P2_RECEIVED_DAMAGE}-${P2_RECEIVED_HEAL})) 	$((${P1_RECEIVED_DAMAGE}-${P1_RECEIVED_HEAL}))>> $LOG_PATH/fight_history.log
fi
}
